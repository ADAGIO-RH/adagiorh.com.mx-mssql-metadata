USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoCambiosDePuesto](
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
      
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))    
      
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
		,@FechaFin		= @FechaFin
		,@dtFiltros		= @dtFiltros
		,@IDUsuario		= @IDUsuario

	if object_id('tempdb..#tempPuestoActual') is not null drop table #tempPuestoActual;
	if object_id('tempdb..#tempPuestoAnterior') is not null drop table #tempPuestoAnterior;

	select e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Division
		,pe.*
		,p.Codigo as CodigoPuestoActual
		,JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as PuestoActual
	INTO #tempPuestoActual
	from RH.tblPuestoEmpleado pe
		join @empleados e on pe.IDEmpleado = e.IDEmpleado
		join RH.tblCatPuestos p on pe.IDPuesto = p.IDPuesto
		left join (
			select m.*,tm.Descripcion as TipoMov
			from IMSS.tblMovAfiliatorios m
				join IMSS.tblCatTipoMovimientos tm on m.IDTipoMovimiento = tm.IDTipoMovimiento
			where tm.Codigo in ('A','R')
		) mov on pe.IDEmpleado = mov.IDEmpleado and pe.FechaIni = mov.Fecha	
	where pe.FechaIni between @FechaIni and @FechaFin and mov.IDMovAfiliatorio is null
	order by e.ClaveEmpleado

	select e.ClaveEmpleado
		,pe.*
		,p.Codigo as CodigoPuestoAnterior
		,p.Descripcion as [PuestoAnterior]
	INTO #tempPuestoAnterior
	from RH.tblPuestoEmpleado pe
		join @empleados e on pe.IDEmpleado = e.IDEmpleado
		join #tempPuestoActual temp on pe.IDEmpleado = temp.IDEmpleado
		join RH.tblCatPuestos p on pe.IDPuesto = p.IDPuesto
	where cast(dateadd(day,-1,temp.FechaIni) as date) between pe.FechaIni and pe.FechaFin
	order by e.ClaveEmpleado
	
	select actual.ClaveEmpleado
		,actual.NOMBRECOMPLETO as Nombre
		,actual.Departamento
		,actual.Division
		,anterior.CodigoPuestoAnterior	as [Código del Puesto Anterior]
		,anterior.PuestoAnterior		as [Puesto Anterior]
		,actual.CodigoPuestoActual		as [Código del Puesto Actual]
		,actual.PuestoActual			as [Puesto Actual]
		,format(actual.FechaIni,'dd/MM/yyyy') as [Fecha Inicial]
		,format(actual.FechaFin,'dd/MM/yyyy') as [Fecha Fin]
	from #tempPuestoActual actual
		join #tempPuestoAnterior anterior on actual.IDEmpleado = anterior.IDEmpleado
	order by actual.ClaveEmpleado
GO
