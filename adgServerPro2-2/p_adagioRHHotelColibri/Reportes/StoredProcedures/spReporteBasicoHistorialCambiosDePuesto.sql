USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoHistorialCambiosDePuesto](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
)
as
	declare 
		@empleados RH.dtEmpleados
		,@FechaIni date --= '2010-01-20'
		,@FechaFin date	--= '2020-01-20'
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20) 
		
		,@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null    
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

	select 
		@FechaIni = isnull(@FechaIni,'1900-01-01')
		,@FechaFin = isnull(@FechaFin,getdate())
	
	insert @empleados
	exec RH.spBuscarEmpleados 
		@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoFin
		,@FechaIni		= @FechaIni
		,@FechaFin		= @Fechafin
		,@dtFiltros		= @dtFiltros
		,@IDUsuario		= @IDUsuario



    Select 
    ClaveEmpleado,
    NOMBRECOMPLETO,
    @FechaIni as Fecha_Vigencia,
    Sucursal,
    Departamento,
    Puesto
    from @empleados


	-- if object_id('tempdb..#tempDepartamentos') is not null drop table #tempDepartamentos;

	-- select E.ClaveEmpleado
	-- 		,CD.Codigo		AS CodigoDEP
	-- 		,CD.Descripcion AS Departamento
	-- 		,DE.FechaIni	AS FechaIniDep
	-- 		,DE.FechaFin	AS FechaFinDEp
	-- 		INTO #tempDepartamentos
	-- 		from rh.tblPuestoEmpleado PE with (nolock)
	-- 		join rh.tblEmpleados E with (nolock) on E.IDEmpleado = PE.IDEmpleado
	-- 		join rh.tblCatPuestos CP with (nolock) on CP.IDPuesto = PE.IDPuesto
	-- 		join rh.tblDepartamentoEmpleado DE with (nolock) on DE.IDEmpleado = E.IDEmpleado and DE.FechaIni between PE.FechaIni and PE.FechaFin
	-- 		join rh.tblCatDepartamentos CD with (nolock) on CD.IDDepartamento = DE.IDDepartamento

	-- select	e.ClaveEmpleado
	-- 		,e.NOMBRECOMPLETO
	-- 		,CASE WHEN (CD.Codigo is null) then (select CodigoDEP from #tempDepartamentos TD where TD.ClaveEmpleado = e.ClaveEmpleado and pe.FechaIni between TD.FechaIniDep and TD.FechaFinDep) else CD.Codigo END AS CodigoDep
	-- 		,CASE WHEN (CD.Descripcion is null) then (select Departamento from #tempDepartamentos TD where TD.ClaveEmpleado = e.ClaveEmpleado and pe.FechaIni between TD.FechaIniDep and TD.FechaFinDep ) else CD.Descripcion END AS Departamento
	-- 		,format(CASE WHEN (DE.FechaIni is null) then(select FechaIniDep from #tempDepartamentos TD where TD.ClaveEmpleado = e.ClaveEmpleado and pe.FechaIni between TD.FechaIniDep and TD.FechaFinDep ) else DE.FechaIni END,'dd/MM/yyyy') AS FechaIniDepartamento
	-- 		,format(CASE WHEN (DE.FechaFin is null) then(select FechaFinDEp from #tempDepartamentos TD where TD.ClaveEmpleado = e.ClaveEmpleado and pe.FechaIni between TD.FechaIniDep and TD.FechaFinDep ) else DE.FechaFin END,'dd/MM/yyyy') AS FechaFinDepartamento
	-- 		,p.Codigo as CodigoPuesto
	-- 		,p.Descripcion as Puesto
	-- 		,format(pe.FechaIni,'dd/MM/yyyy') as FechaInicialPuesto
	-- 		,format(pe.FechaFin,'dd/MM/yyyy') as FechaFinPuesto
	-- 	from RH.tblPuestoEmpleado pe with (nolock)
	-- 		join @empleados e on pe.IDEmpleado = e.IDEmpleado
	-- 		join RH.tblCatPuestos p with (nolock) on pe.IDPuesto = p.IDPuesto
	-- 		left join rh.tblDepartamentoEmpleado DE with (nolock) on DE.IDEmpleado = E.IDEmpleado and DE.FechaIni between PE.FechaIni and PE.FechaFin
	-- 		left join rh.tblCatDepartamentos CD with (nolock) on CD.IDDepartamento = DE.IDDepartamento
	-- 		--left join (
	-- 		--	select m.*,tm.Descripcion as TipoMov
	-- 		--	from IMSS.tblMovAfiliatorios m with (nolock)
	-- 		--		join IMSS.tblCatTipoMovimientos tm with (nolock) on m.IDTipoMovimiento = tm.IDTipoMovimiento
	-- 		--	where tm.Codigo in ('A','R')
	-- 		--) mov on pe.IDEmpleado = mov.IDEmpleado and pe.FechaIni = mov.Fecha	
	-- 	--where pe.FechaIni between @FechaIni and @FechaFin --and mov.IDMovAfiliatorio is null
	-- 	order by e.ClaveEmpleado,pe.FechaIni

	
GO
