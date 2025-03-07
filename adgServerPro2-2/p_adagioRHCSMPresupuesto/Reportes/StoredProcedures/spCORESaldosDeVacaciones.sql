USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Reportes].[spCORESaldosDeVacaciones](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
	
	declare 
		 @empleados RH.dtEmpleados
		,@FechaIni date --= '2010-01-20'
		,@FechaFin date	--= '2021-01-20'
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20) 
		,@IDTipoNomina int  
		
		,@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null   
		,@IDEmpleado int
		,@tempDiasVacacionesRep [Asistencia].[dtSaldosDeVacaciones]
	;

	SET DATEFIRST 7;      
      
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx') 
      
	select @IdiomaSQL = [SQL]      
	from app.tblIdiomas with (nolock)      
	where IDIdioma = @IDIdioma      
      
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)      
	begin      
		set @IdiomaSQL = 'Spanish' ;      
	end      
        
	SET LANGUAGE @IdiomaSQL;  

	SET @FechaIni		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) as date)    
	SET @FechaFin		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) as date)  
	SET @EmpleadoIni	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')   
	SET @IDTipoNomina	= ISNULL((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)    

	select 
		@FechaIni = isnull(@FechaIni,'1900-01-01')
		,@FechaFin = isnull(@FechaFin,getdate())



	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario
	
	DECLARE @TableSaldos as Table(
		IDEmpleado int,
		Anio int,
		FechaIni date,
		FechaFin date,
		Dias decimal(18,2),
		DiasTomados decimal(18,2),
		DiasVencidos decimal(18,2),
		DiasDisponibles decimal(18,2),
		TipoPrestacion Varchar(500),
		Errores Varchar(500)

	)

	select @IDEmpleado = min(IDEmpleado) from @empleados

	WHILE (@IDEmpleado <= (SELECT MAX(IDEmpleado) from @empleados))
	BEGIN
		BEGIN TRY
			insert @tempDiasVacacionesRep
			EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado,@Proporcional = null, @FechaBaja = null, @IDUsuario = @IDUsuario
		END TRY
		BEGIN CATCH
			print ERROR_MESSAGE() 
			INSERT INTO @TableSaldos(IDEmpleado, Errores)
			SELECT @IDEmpleado,ERROR_MESSAGE()
		END CATCH

		INSERT INTO @TableSaldos
		SELECT @IDEmpleado, Anio, FechaIni, FechaFin, Dias, DiasTomados, DiasVencidos, DiasDisponibles, TipoPrestacion ,''
		FROM @tempDiasVacacionesRep

		Delete @tempDiasVacacionesRep

		SELECT @IDEmpleado = min(IDEmpleado) from @empleados where IDEmpleado > @IDEmpleado
	END
	
	select 
		 e.ClaveEmpleado as CLAVE
		,e.NOMBRECOMPLETO as NOMBRE
		,e.DEPARTAMENTO
		,e.SUCURSAL
		,e.PUESTO
		,e.DIVISION
		,JSON_VALUE(TP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS [TIPO PRESTACIÓN]
		,FORMAT(CAST(e.fechaAntiguedad AS DATE),'dd/MM/yyyy') as FECHA_DE_ANTIGUEDAD
		,vacaciones.Anio							AS [ANTIGUEDAD_AÑOS]
		,vacaciones.DiasPorAniosPrestacion			AS [VACACIONES_AÑO_ACTUAL]
		,vacaciones.VacacionesGeneradasDesdeIngreso AS [VACACIONES_GENERADAS]
		--,vacaciones.DiasPorAnio						AS [VACACIONES_PROPORCIONALES]
		,vacaciones.DiasTomados						AS [DIAS_TOMADOS]
		,vacaciones.DiasVencidos				    AS [DIAS_VENCIDOS]
		,vacaciones.DiasDisponibles					AS [VACACIONES_DISPONIBLES]
		,vacaciones.Errores							AS [ERRORES]
		--,((vacaciones.VacacionesGeneradasDesdeIngreso - vacaciones.DiasTomados) - vacaciones.DiasVencidos) AS [VACACIONES_POR_DISFRUTAR]
		--,vacaciones.DiasTomadosAnioActual
	from (
			Select s.IDEmpleado
			,max(s.Anio) as Anio
			,MAX(s.Dias) as DiasPorAniosPrestacion
			,SUM(s.Dias) as VacacionesGeneradasDesdeIngreso
			,SUM(s.DiasTomados) as DiasTomados
			,SUM(s.DiasVencidos) as DiasVencidos
			,SUM(s.DiasDisponibles) as DiasDisponibles
			,S.Errores as Errores
			FROM @TableSaldos s
			GROUP BY s.IDEmpleado, s.Errores
	) vacaciones
		join @empleados e on vacaciones.IDEmpleado = e.IDEmpleado
		left join RH.tblCatTiposPrestaciones TP
			on e.IDTipoPrestacion = TP.IDTipoPrestacion
	order by e.ClaveEmpleado, vacaciones.Anio asc
GO
