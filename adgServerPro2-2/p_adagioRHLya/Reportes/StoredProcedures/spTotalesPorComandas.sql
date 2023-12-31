USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [Reportes].[spTotalesPorComandas](
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int 
) as
	declare 
		@FechaIni date,
		@FechaFin date

	SET @FechaIni = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	
	select
		FECHA,
		[TOTAL COMANDAS],
		[PRECIO TOTAL]
	from (
		select
			format(p.FechaCreacion,'dd/MM/yyyy') as FECHA
			,p.FechaCreacion
			,count(p.IDPedido) as [TOTAL COMANDAS]
			,sum(p.GrandTotal) as [PRECIO TOTAL]
		from Comedor.tblPedidos p with (nolock)
		where p.FechaCreacion between @FechaIni and @FechaFin
			and isnull([p].Autorizado,0) = 1
			and isnull([p].Cancelada,0) = 0
		group by p.FechaCreacion
	) as info
	order by FechaCreacion asc
GO
