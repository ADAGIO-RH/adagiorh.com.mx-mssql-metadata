USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Dashboard].[spBuscarAltasBajasReingreso](
		@dtFiltros [Nomina].[dtFiltrosRH] readonly,
		@IDUsuario int  
) as
	--declare 
	--	@dtFiltros [Nomina].[dtFiltrosRH],
	--	@IDUsuario int  = 1

	--insert @dtFiltros
	--values 
	--	('FechaIni','2020-01-01')
	--	,('FechaFin','2020-01-31')

	declare
		@dtEmpleados [RH].[dtEmpleados]
		,@FechaIni date
		,@FechaFin date
		,@dtFechas [App].[dtFechas]
	;

	set @FechaIni = isnull((SELECT top 1 cast([Value] as date) from @dtFiltros where Catalogo = 'FechaIni'),'1990-01-01')
	set @FechaFin = isnull((SELECT top 1 cast([Value] as date) from @dtFiltros where Catalogo = 'FechaFin'),'9999-12-31')

	insert @dtFechas
	exec [App].[spListaFechas] @FechaIni = @FechaIni, @FechaFin = @FechaFin

	insert into @dtEmpleados
	Exec [RH].[spBuscarEmpleadosMaster] 
		@FechaIni	= @FechaIni
		,@FechaFin	= @FechaFin
		,@dtFiltros = @dtFiltros
		,@IDUsuario	= @IDUsuario

	-- ALTAS
	select 
		isnull(movimientos.Movimiento,'SIN MOVIMIENTOS') Movimiento
		,isnull(movimientos.Fecha,FORMAT(f.Fecha,'dd/MM/yyyy')) as Fecha
		,isnull(movimientos.Total,0) as Total
	from @dtFechas f
		left join (
			select tm.Descripcion as Movimiento,FORMAT(m.Fecha,'dd/MM/yyyy') as Fecha,m.Fecha as FechaMov,count(*) as Total
			from [IMSS].[tblMovAfiliatorios] m with (nolock)
				join [IMSS].[tblCatTipoMovimientos] tm with (nolock) on m.IDTipoMovimiento = tm.IDTipoMovimiento
				join @dtEmpleados e on m.IDEmpleado = e.IDEmpleado
			where m.Fecha between @FechaIni and @FechaFin and tm.Codigo = 'A'
			group by tm.Descripcion, m.Fecha
		) movimientos on f.Fecha = movimientos.FechaMov

	-- BAJAS
	select 
		isnull(movimientos.Movimiento,'SIN MOVIMIENTOS') Movimiento
		,isnull(movimientos.Fecha,FORMAT(f.Fecha,'dd/MM/yyyy')) as Fecha
		,isnull(movimientos.Total,0) as Total
	from @dtFechas f
		left join (
			select tm.Descripcion as Movimiento,FORMAT(m.Fecha,'dd/MM/yyyy') as Fecha,m.Fecha as FechaMov,count(*) as Total
			from [IMSS].[tblMovAfiliatorios] m with (nolock)
				join [IMSS].[tblCatTipoMovimientos] tm with (nolock) on m.IDTipoMovimiento = tm.IDTipoMovimiento
				join @dtEmpleados e on m.IDEmpleado = e.IDEmpleado
			where m.Fecha between @FechaIni and @FechaFin and tm.Codigo = 'B'
			group by tm.Descripcion, m.Fecha
		) movimientos on f.Fecha = movimientos.FechaMov

	-- REINGRESOS
	select 
		isnull(movimientos.Movimiento,'SIN MOVIMIENTOS') Movimiento
		,isnull(movimientos.Fecha,FORMAT(f.Fecha,'dd/MM/yyyy')) as Fecha
		,isnull(movimientos.Total,0) as Total
	from @dtFechas f
		left join (
			select tm.Descripcion as Movimiento,FORMAT(m.Fecha,'dd/MM/yyyy') as Fecha,m.Fecha as FechaMov,count(*) as Total
			from [IMSS].[tblMovAfiliatorios] m with (nolock)
				join [IMSS].[tblCatTipoMovimientos] tm with (nolock) on m.IDTipoMovimiento = tm.IDTipoMovimiento
				join @dtEmpleados e on m.IDEmpleado = e.IDEmpleado
			where m.Fecha between @FechaIni and @FechaFin and tm.Codigo = 'R'
			group by tm.Descripcion, m.Fecha
		) movimientos on f.Fecha = movimientos.FechaMov

	--select * from IMSS.tblCatTipoMovimientos
GO
