USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spCORESaldosDeVacaciones](
	@dtFiltros Nomina.dtFiltrosRH READONLY,
	@IDUsuario INT
) AS
BEGIN
	-- Declare variables
	DECLARE 
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

	-- Set configuration
	SET DATEFIRST 7;      
      
	-- Get user language preference
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx') 
      
	select @IdiomaSQL = [SQL]      
	from app.tblIdiomas with (nolock)      
	where IDIdioma = @IDIdioma      
      
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)      
	begin      
		set @IdiomaSQL = 'Spanish' ;      
	end      
        
	SET LANGUAGE @IdiomaSQL;  

	-- Extract filter parameters
	SET @FechaIni		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) as date)    
	SET @FechaFin		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) as date)  
	SET @EmpleadoIni	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')   
	SET @IDTipoNomina	= ISNULL((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)    

	-- Set default dates if null
	select 
		@FechaIni = isnull(@FechaIni,'1900-01-01')
		,@FechaFin = isnull(@FechaFin,getdate())

	-- Get employees based on filters
	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario
	
	-- Create temporary table for balance results
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

	-- Process each employee 
	select @IDEmpleado = min(IDEmpleado) from @empleados

	WHILE (@IDEmpleado <= (SELECT MAX(IDEmpleado) from @empleados))
	BEGIN
		BEGIN TRY
			-- Get vacation balances for current employee
			insert @tempDiasVacacionesRep
			EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado,@Proporcional = null, @FechaBaja = null, @IDUsuario = @IDUsuario
		END TRY
		BEGIN CATCH
			print ERROR_MESSAGE() 
			INSERT INTO @TableSaldos(IDEmpleado, Errores)
			SELECT @IDEmpleado,ERROR_MESSAGE()
		END CATCH

		-- Store results in temporary table
		INSERT INTO @TableSaldos
		SELECT @IDEmpleado, Anio, FechaIni, FechaFin, Dias, DiasTomados, DiasVencidos, DiasDisponibles, TipoPrestacion ,''
		FROM @tempDiasVacacionesRep

		-- Clear temporary table for next employee
		Delete @tempDiasVacacionesRep

		-- Get next employee
		SELECT @IDEmpleado = min(IDEmpleado) from @empleados where IDEmpleado > @IDEmpleado
	END
	
	-- Generate final report
	select 
		 e.ClaveEmpleado as CLAVE
		,e.NOMBRECOMPLETO as NOMBRE
		,e.DEPARTAMENTO
		,e.SUCURSAL
		,e.PUESTO
		,e.DIVISION
		,JSON_VALUE(TP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS [TIPO PRESTACIÓN]
		,FORMAT(CAST(e.fechaAntiguedad AS DATE),'dd/MM/yyyy') as FECHA_DE_ANTIGUEDAD
		,vacaciones.AntiguedadAnios					AS [ANTIGUEDAD_AÑOS]
		--,vacaciones.Anio							AS [AÑO_EN_CURSO_DISPONIBLE]
		,vacaciones.DiasPorAniosPrestacion			AS [VACACIONES_AÑO_ACTUAL]
		,vacaciones.VacacionesGeneradasDesdeIngreso AS [VACACIONES_GENERADAS]
		,vacaciones.DiasTomados						AS [DIAS_TOMADOS]
		,vacaciones.DiasVencidos				    AS [DIAS_VENCIDOS]
		,vacaciones.DiasDisponibles					AS [VACACIONES_DISPONIBLES]
		,vacaciones.Errores							AS [ERRORES]
	from (
			Select s.IDEmpleado
			,max(s.Anio) as Anio
			,MAX(s.Dias) as DiasPorAniosPrestacion
			,SUM(s.Dias) as VacacionesGeneradasDesdeIngreso
			,SUM(s.DiasTomados) as DiasTomados
			,SUM(s.DiasVencidos) as DiasVencidos
			,SUM(s.DiasDisponibles) as DiasDisponibles
			,S.Errores as Errores
			,CAST(DATEDIFF(DAY,MIN(FechaIni), GETDATE()) / 365.25 AS Decimal(18,2)) as AntiguedadAnios
			FROM @TableSaldos s
			GROUP BY s.IDEmpleado, s.Errores
	) vacaciones
		join @empleados e on vacaciones.IDEmpleado = e.IDEmpleado
		left join RH.tblCatTiposPrestaciones TP
			on e.IDTipoPrestacion = TP.IDTipoPrestacion
	order by e.ClaveEmpleado, vacaciones.Anio asc
END
GO
