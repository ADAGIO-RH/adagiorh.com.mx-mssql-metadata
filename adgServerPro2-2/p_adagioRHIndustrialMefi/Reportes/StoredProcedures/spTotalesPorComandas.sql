USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spTotalesPorComandas](
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int 
) as
	declare 
		@FechaIni date,
		@FechaFin date,
		@IDRestaurante int
	;
	
	SET @IDRestaurante = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRestaurante'),','))
	SET @FechaIni = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	
	select
		Restaurante,
		FECHA,
		[TOTAL COMANDAS],
		[PRECIO TOTAL]
	from (
		select
			r.Nombre as Restaurante
			,format(p.FechaCreacion,'dd/MM/yyyy') as FECHA
			,p.FechaCreacion
			,count(p.IDPedido) as [TOTAL COMANDAS]
			,sum(p.GrandTotal) as [PRECIO TOTAL]
		from Comedor.tblPedidos p with (nolock)
			join Comedor.tblCatRestaurantes r on r.IDRestaurante = p.IDRestaurante
		where p.FechaCreacion between @FechaIni and @FechaFin
			and isnull([p].Autorizado,0) = 1
			and isnull([p].Cancelada,0) = 0
			and (p.IDRestaurante = @IDRestaurante or isnull(@IDRestaurante, 0) = 0)
		group by r.Nombre, p.FechaCreacion
	) as info
	order by Restaurante, FechaCreacion asc
GO
