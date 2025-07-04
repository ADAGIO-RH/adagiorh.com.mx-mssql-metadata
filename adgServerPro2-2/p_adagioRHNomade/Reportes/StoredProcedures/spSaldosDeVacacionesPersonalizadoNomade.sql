USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Calcula el historial de saldos de vacaciones de un colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2019-01-01  
** Paremetros  :                
  
 Si se modifica el result set de este sp será necesario modificar los siguientes SP's:  
  [Asistencia].[spBuscarVacacionesPendientesEmpleado]  
  
** DataTypes Relacionados:   [Asistencia].[dtSaldosDeVacaciones]  
  
  select * from RH.tblEmpleadosMaster where claveEmpleado= 'adg0001'
[Asistencia].[spBuscarSaldosVacacionesPorAnios] 1279,1,1  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2021-11-30				Aneudy Abreu	Se agrega validación para cuando el colaborador tiene más
										de una Prestación
2022-01-01				Aneudy Abreu	Se agregó validación del historial de prestaciones
2022-01-01				Julio Castillo	Se agregó el parámetro de FechaBaja
***************************************************************************************************/ 
CREATE proc [Reportes].[spSaldosDeVacacionesPersonalizadoNomade](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
		-- Parámetros
	--declare 
	--	@dtFiltros Nomina.dtFiltrosRH		
	--	,@IDUsuario int = 1
	--;

	--insert @dtFiltros
	--values
	--	('ClaveEmpleadoInicial','03001')
	--	,('ClaveEmpleadoFinal','03001')
	--	,('FechaIni','2021-03-19')
	--	,('FechaFin','2021-03-19')

	declare 
		 @empleados RH.dtEmpleados
		,@FechaIni date --= '2010-01-20'
		,@FechaFin date	--= '2021-01-20'
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20) 
		,@IDTipoNomina int  
		,@totalVacaciones int = 0
		,@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null 
		,@counter int = 1
		,@idempleado int
		,@vencidas int 
		,@Tomados int = 0
		,@Disponibles int
		,@DiasPrestacion int
		,@Antiguedad int
		,@FechaAntiguedad date
	;

	SET DATEFIRST 7;      
      
	select top 1 
		@IDIdioma = dp.Valor      
	from Seguridad.tblUsuarios u with (nolock)     
		Inner join App.tblPreferencias p with (nolock)      
			on u.IDPreferencia = p.IDPreferencia      
		Inner join App.tblDetallePreferencias dp with (nolock)      
			on dp.IDPreferencia = p.IDPreferencia      
		Inner join App.tblCatTiposPreferencias tp with (nolock)      
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia      
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'      
      
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

	if object_id('tempdb..#tempVacacionesTomadas') is not null drop table #tempVacacionesTomadas;  
	if object_id('tempdb..#tempCTEDos') is not null drop table #tempCTEDos;  

	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	
  
  --select * from cteAntiguedad
  --return
	select e.*
		,cast(0 as float) as DiasTomados  
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,cast(0 as float)  as DiasPorAniosPrestacion
	INTO #tempCTEDos  
	from @empleados e
    inner join rh.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado

	IF object_ID('TEMPDB..#TempTotalVaca') IS NOT NULL DROP TABLE #TempTotalVaca 
	IF object_ID('TEMPDB..#TempEmpleados') IS NOT NULL DROP TABLE #TempEmpleados

	select @counter = min( e.idempleado) from @empleados e inner join rh.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado
	declare @tblTempVacaciones as table(
					Anio int
					,FechaIni date
					,FechaFin date
					,Dias int
					,DiasGenerados int
					,DiasTomados int
					,DiasVencidos int
					,DiasDisponibles decimal(18,2)
					,prestacion varchar(max)
					,FechaIniDisponible date
					,FechaFinDisponible date
	)
	

	while (@counter <= (select max(e.idempleado) from @empleados e inner join rh.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado))
	begin	
	
		set @vencidas = 0
		set @Tomados = 0
		set @Disponibles = 0
		select @idempleado =  idempleado , @FechaAntiguedad = FechaIngreso from @empleados where IDEmpleado = @counter
		

	
		
		--select @idempleado
		delete from @tblTempVacaciones
		
		insert into @tblTempVacaciones
		exec [Asistencia].[spBuscarSaldosVacacionesPorAnios_NOMADE] @idempleado = @idempleado, @proporcional = 0,@FechaBaja= @fechafin,@IDUsuario= @IDUsuario
		
		SET @vencidas = ISNULL((SELECT SUM(isnull(DiasVencidos,0))  FROM @tblTempVacaciones) ,0)
		SET @Tomados = ISNULL((Select SUM(isnull(DiasTomados,0)) FROM @tblTempVacaciones) ,0)
		SET @Disponibles = ISNULL((Select SUM(isnull(DiasDisponibles,0)) FROM @tblTempVacaciones) ,0)
		SET @DiasPrestacion= ISNULL((Select SUM(isnull(Dias,0)) FROM @tblTempVacaciones) ,0)
					
		
		update cte 
			set DiasVencidos = @vencidas
			, DiasTomados = @Tomados 
			, DiasDisponibles= @Disponibles
			, DiasPorAniosPrestacion= @DiasPrestacion
		FROM #tempCTEDos cte
			 where IDEmpleado = @idempleado 
	
		select @counter =  min(e.idempleado) from @empleados e inner join rh.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado where e.IDEmpleado > @counter


	end
	
	select 
		ClaveEmpleado  as [Clave Empleado],
		NOMBRECOMPLETO as [Nombre Completo],
		FORMAT(FechaAntiguedad,'dd/MM/yyyy') as [Fecha Antigüedad],
		Departamento,
		Sucursal,
		Puesto,
		tp.Descripcion as [Prestación],
		DATEDIFF(DAY,FechaAntiguedad,@FechaFin)/365.24 as Antiguedad,
		DiasPorAniosPrestacion as [Dias Totales],
		DiasTomados as [Días Tomados],
		DiasVencidos as [Días Vencidos],
		DiasDisponibles as [Días Disponibles]
	from #tempCTEDos d
		left join RH.tblCatTiposPrestaciones tp
			on d.IDTipoPrestacion = tp.IDTipoPrestacion
	ORDER BY ClaveEmpleado asc
	
GO
