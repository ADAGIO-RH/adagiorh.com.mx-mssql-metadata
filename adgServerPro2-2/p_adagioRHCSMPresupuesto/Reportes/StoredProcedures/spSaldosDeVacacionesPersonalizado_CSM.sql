USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--GO
--/****** Object:  StoredProcedure [Reportes].[spSaldosDeVacaciones]    Script Date: 3/19/2020 12:57:49 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

/*****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2022-11-01			Jose Roman			Se creo el reporte
2023-01-16			Julio Castillo		Se le agregó validaciones para que no truene el procedimiendo con el RETURN ERROR del 
										calculo de vacaciones con colaboradores con 0 años de antiguedad sin proporcional.
***************************************************************************************************/  
CREATE proc [Reportes].[spSaldosDeVacacionesPersonalizado_CSM](
	 @dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
	
	declare 
		 @empleados RH.dtEmpleados
		,@FechaIni date 
		,@FechaFin date	
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
        ,@UltimaPrestacion varchar(max)
		,@tblTempVacaciones [Asistencia].[dtSaldosDeVacaciones]
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
	if object_id('tempdb..#tempCTEtres') is not null drop table #tempCTEtres;    
	if object_id('tempdb..#zeroEmpleados') is not null drop table #zeroEmpleados;

	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	select e.*
		,cast(0 as float) as DiasTomados  
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,cast(0 as float)  as DiasPorAniosPrestacion
        ,cast( 'Prestacion' as varchar(MAX)) as UltimaPrestacion
	INTO #tempCTEDos  
	from @empleados e

	select e.*
		,cast(0 as float) as DiasTomados  
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,cast(0 as float)  as DiasPorAniosPrestacion
        ,cast( 'Aun no cumple la antiguedad' as varchar(MAX)) as UltimaPrestacion
	INTO #tempCTEtres  
	from @empleados e
	left join rh.tblConfiguracionesCliente cf on cf.IDCliente = e.IDCliente and IDTipoConfiguracionCliente = 'VacacionesProporcionales'
		where (DATEDIFF(day,FechaIngreso,@FechaFin) / 365.2425 ) < 1 and (cf.Valor = 'false' or cf.Valor is null )
  

	delete #tempCTEDos
	where IDEmpleado in (Select IDEmpleado from #tempCTEtres)


	IF object_ID('TEMPDB..#TempTotalVaca') IS NOT NULL DROP TABLE #TempTotalVaca 
	IF object_ID('TEMPDB..#TempEmpleados') IS NOT NULL DROP TABLE #TempEmpleados

	select @counter = min( idempleado) from #tempCTEDos

	--declare @tblTempVacaciones as table(
	--				Anio int
	--				,FechaIni date
	--				,FechaFin date
	--				,Dias int
	--				,DiasTomados int
	--				,DiasVencidos int
	--				,DiasDisponibles decimal(18,2)
	--				,prestacion varchar(max)
	--				,FechaIniDisponible DATE
 --                   ,FechaFinDisponible DATE
	--)
	

	while (@counter <= (select max(idempleado) from #tempCTEDos))
	begin	
	
		set @vencidas = 0
		set @Tomados = 0
		set @Disponibles = 0
		select @idempleado =  idempleado , @FechaAntiguedad = FechaIngreso from #tempCTEDos where IDEmpleado = @counter
		

	
		
		
		delete from @tblTempVacaciones

		insert into @tblTempVacaciones
		exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @idempleado = @idempleado, @proporcional = null,@FechaBaja= @fechafin,@IDUsuario= @IDUsuario
		
		SET @vencidas = ISNULL((SELECT SUM(isnull(DiasVencidos,0))  FROM @tblTempVacaciones) ,0)
		SET @Tomados = ISNULL((Select SUM(isnull(DiasTomados,0)) FROM @tblTempVacaciones) ,0)
		SET @Disponibles = ISNULL((Select SUM(isnull(DiasDisponibles,0)) FROM @tblTempVacaciones) ,0)
		SET @DiasPrestacion= ISNULL((Select SUM(isnull(Dias,0)) FROM @tblTempVacaciones) ,0)
        SET @UltimaPrestacion = ISNULL((Select MAX(TipoPrestacion) FROM @tblTempVacaciones) ,0)
					
		
		update cte 
			set DiasVencidos = @vencidas
			, DiasTomados = @Tomados 
			, DiasDisponibles= @Disponibles
			, DiasPorAniosPrestacion= @DiasPrestacion
            , UltimaPrestacion = @UltimaPrestacion
		FROM #tempCTEDos cte
			 where IDEmpleado = @idempleado 
	
		select @counter =  min(idempleado) from #tempCTEDos where IDEmpleado > @counter


	end
	
	select
		ClaveEmpleado  as [Clave Empleado],
		NOMBRECOMPLETO as [Nombre Completo],
		FORMAT(FechaIngreso,'dd/MM/yyyy') as [Fecha Antigüedad],
		Departamento,
		Sucursal,
		Puesto,
		UltimaPrestacion as [Prestación],
		DATEDIFF(DAY,FechaIngreso,@FechaFin) / 365.2425 as Antiguedad,
		DiasPorAniosPrestacion as DiasTotales,
		DiasTomados as [Días Tomados],
		DiasVencidos as [Días Vencidos],
		DiasDisponibles as [Días Disponibles]

        
	from (select * from #tempCTEDos union select * from #tempCTEtres) d
		left join RH.tblCatTiposPrestaciones tp
			on d.IDTipoPrestacion = tp.IDTipoPrestacion
	ORDER BY ClaveEmpleado asc
	

GO
