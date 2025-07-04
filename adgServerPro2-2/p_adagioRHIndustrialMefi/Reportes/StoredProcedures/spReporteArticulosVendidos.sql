USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [d_adagioRH_1_5]
--GO
--/****** Object:  StoredProcedure [Reportes].[spReporteArticulosVendidos]    Script Date: 7/23/2021 1:26:11 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

CREATE proc [Reportes].[spReporteArticulosVendidos](
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int
) as

--declare @dtFiltros Nomina.dtFiltrosRH 
--,@IDUsuario int  =1
--	insert @dtFiltros(Catalogo, Value)
--	values ('IDRestaurante', '2')
--		,('FechaIni', '2020-04-01')
--		,('FechaFin', '2022-04-01')

	declare 
		@FechaIni date,	-- = '2021-07-22',
		@FechaFin date, -- = '2021-07-23',
		@IDRestaurante int
	;

	SET @FechaIni = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	SET @IDRestaurante = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRestaurante'),','))
	
	declare @resp as table (
		Restaurante varchar(max),
		ArticuloMenu varchar(max),
		Categoria varchar(max),
		TipoArticulo varchar(max),
		Cantidad int default 0,
		CostoUnitario money default 0,
		CostoTotal as Cantidad * CostoUnitario,
		PrecioUnidad money default 0,
		PrecioUnitarioSinIVA as PrecioUnidad / 1.16,
		Subtotal money,-- as Cantidad * PrecioUnidad,
		IVA money, -- as Subtotal  / 0.16,
		VentaTotalConIVA money, --as Subtotal + IVA
		Tipo varchar(50)
	)
	
	insert @resp(Restaurante, ArticuloMenu, Categoria, TipoArticulo, Cantidad, CostoUnitario, PrecioUnidad, Tipo)
	select 
		r.Nombre as Restaurante
		,dpa.Nombre as ArticuloMenu
		,c.Nombre as CATEGORIA
		,cta.Nombre as [TIPO DE ARTICULO]
		,count(dpa.IDArticulo) as [CANTIDAD]
		,isnull(a.PrecioCosto, 0) as [COSTO UNITARIO]
	--	,count(dpa.IDArticulo) * isnull(a.PrecioCosto, 0) as [COSTO TOTAL]
	--	,isnull(dpa.PrecioUnidad, 0) * 1.16 as [PRECIO UNITARIO CON IVA]
		,isnull(dpa.PrecioUnidad, 0)
		--,cast((dpa.PrecioUnidad / 1.160) as decimal(18,2)) as [PRECIO UNIDAD SIN IVA]
		--,sum(dpa.PrecioUnidad * dpa.Cantidad) as [PRECIO TOTAL]
		--,cast(sum(dpa.PrecioUnidad * dpa.Cantidad) / 1.160 as decimal(18,2)) as [PRECIO TOTAL SIN IVA]
		,'Artículo' as TIPO
	from Comedor.tblPedidos p with (nolock)
		join Comedor.tblDetallePedidoArticulos dpa with (nolock) on dpa.IDPedido = p.IDPedido
		join Comedor.tblCatRestaurantes r with (nolock) on r.IDRestaurante = p.IDRestaurante
		left join Comedor.tblCatArticulos a with (nolock) on a.IDArticulo = dpa.IDArticulo 
		left join Comedor.TblCatCategorias c with (nolock) on c.IDCategoria = a.IDCategoria
		left join Comedor.tblCatTiposArticulos cta with (nolock) on cta.IDTipoArticulo = a.IDTipoArticulo
	where p.FechaCreacion between @FechaIni and @FechaFin
		and isnull([p].Autorizado,0) = 1
		and isnull([p].Cancelada,0) = 0
		and (p.IDRestaurante = @IDRestaurante or isnull(@IDRestaurante, 0) = 0)
	group by r.Nombre, dpa.Nombre, c.Nombre, cta.Nombre, a.PrecioCosto, dpa.PrecioUnidad

	insert @resp(Restaurante, ArticuloMenu, Categoria, TipoArticulo, Cantidad, CostoUnitario, PrecioUnidad, Tipo)
	select 
		r.Nombre as Restaurante
		,ctm.Nombre as [ARTICULO/MENU]
		,'Menú' as CATEGORIA
		,ctm.Nombre as TipoMenu
		,count(dpa.IDMenu) as Cantidad
		,m.PrecioCosto as [COSTO UNITARIO]
		,isnull(dpa.PrecioUnidad, 0)
		--,cast((dpa.PrecioUnidad / 1.160) as decimal(18,2)) as [PRECIO UNIDAD SIN IVA]
		--,sum(dpa.PrecioUnidad * dpa.Cantidad) as [PRECIO TOTAL]
		--,cast(sum(dpa.PrecioUnidad * dpa.Cantidad) / 1.160 as decimal(18,2)) as [PRECIO TOTAL SIN IVA]
		,'Menú' as TIPO
	from Comedor.tblPedidos p with (nolock)
		join Comedor.tblDetallePedidoMenus dpa with (nolock) on dpa.IDPedido = p.IDPedido
		join Comedor.tblCatRestaurantes r on r.IDRestaurante = p.IDRestaurante
		left join Comedor.tblCatMenus m with (nolock) on m.IDMenu = dpa.IDMenu
		left join Comedor.tblCatTiposMenus ctm with (nolock) on ctm.IDTipoMenu = m.IDTipoMenu
	where p.FechaCreacion between @FechaIni and @FechaFin
		and isnull([p].Autorizado, 0) = 1
		and isnull([p].Cancelada, 0) = 0
		and (p.IDRestaurante = @IDRestaurante or isnull(@IDRestaurante, 0) = 0)
	group by r.Nombre, ctm.Nombre, m.PrecioCosto, dpa.PrecioUnidad	

	update @resp
	set Subtotal = PrecioUnitarioSinIVA * Cantidad

	update @resp
	set IVA = Subtotal * 0.16

	update @resp
	set VentaTotalConIVA  = Subtotal + IVA

	select
		Restaurante as RESTAURANTE,
		ArticuloMenu AS [ARTICULO O MENU],
		Categoria AS CATEGORIA,
		TipoArticulo AS [TIPO DE ARTICULO],
		Cantidad CANTIDAD,
		CostoUnitario [COSTO UNITARIO],
		CostoTotal [COSTO TOTAL],
		PrecioUnidad [PRECIO TOTAL],
		cast(PrecioUnitarioSinIVA as decimal(18,2)) as [PRECIO UNITARIO SIN IVA],
		cast(Subtotal as decimal(18,2)) as SUBTOTAL,
		cast(IVA as decimal(18,2)) as [IVA ],
		cast(VentaTotalConIVA  as decimal(18, 2)) as [TOTAL CON IVA],
		Tipo TIPO
	from @resp

	--select *
	--from (
	--	select r.Nombre as Restaurante
	--		,dpa.Nombre as [ARTICULO/MENU]
	--		,c.Nombre as CATEGORIA
	--		,cta.Nombre as [TIPO DE ARTICULO]
	--		,count(dpa.IDArticulo) as [CANTIDAD]
	--		,isnull(a.PrecioCosto, 0) as [COSTO UNITARIO]
	--		,count(dpa.IDArticulo) * isnull(a.PrecioCosto, 0) as [COSTO TOTAL]
	--		,isnull(dpa.PrecioUnidad, 0) * 1.16 as [PRECIO UNITARIO CON IVA]

	--		,cast((dpa.PrecioUnidad / 1.160) as decimal(18,2)) as [PRECIO UNIDAD SIN IVA]
	--		,sum(dpa.PrecioUnidad * dpa.Cantidad) as [PRECIO TOTAL]
	--		,cast(sum(dpa.PrecioUnidad * dpa.Cantidad) / 1.160 as decimal(18,2)) as [PRECIO TOTAL SIN IVA]
	--		,'Artículo' as TIPO
	--	from Comedor.tblPedidos p with (nolock)
	--		join Comedor.tblDetallePedidoArticulos dpa with (nolock) on dpa.IDPedido = p.IDPedido
	--		join Comedor.tblCatRestaurantes r on r.IDRestaurante = p.IDRestaurante
	--		left join Comedor.tblCatArticulos a with (nolock)on a.IDArticulo = dpa.IDArticulo 
	--		left join Comedor.TblCatCategorias c with (nolock) on c.IDCategoria = a.IDCategoria
	--		left join Comedor.tblCatTiposArticulos cta with (nolock) on cta.IDTipoArticulo = a.IDTipoArticulo
	--	where p.FechaCreacion between @FechaIni and @FechaFin
	--		and isnull([p].Autorizado,0) = 1
	--		and isnull([p].Cancelada,0) = 0
	--		and (p.IDRestaurante = @IDRestaurante or isnull(@IDRestaurante, 0) = 0)
	--	group by r.Nombre, dpa.Nombre, c.Nombre, dpa.PrecioUnidad
	--	union all
	--	select r.Nombre as Restaurante
	--		,ctm.Nombre as [ARTICULO/MENU]
	--		,'Menú' as CATEGORIA
	--		,dpa.PrecioUnidad as [PRECIO UNIDAD]
	--		,cast((dpa.PrecioUnidad / 1.160) as decimal(18,2)) as [PRECIO UNIDAD SIN IVA]
	--		,count(dpa.IDMenu) as [TOTAL UNIDADES]
	--		,sum(dpa.PrecioUnidad * dpa.Cantidad) as [PRECIO TOTAL]
	--		,cast(sum(dpa.PrecioUnidad * dpa.Cantidad) / 1.160 as decimal(18,2)) as [PRECIO TOTAL SIN IVA]
	--		,'Menú' as TIPO
	--	from Comedor.tblPedidos p with (nolock)
	--		join Comedor.tblDetallePedidoMenus dpa with (nolock) on dpa.IDPedido = p.IDPedido
	--		join Comedor.tblCatRestaurantes r on r.IDRestaurante = p.IDRestaurante
	--		left join Comedor.tblCatMenus m with (nolock) on m.IDMenu = dpa.IDMenu
	--		left join Comedor.tblCatTiposMenus ctm with (nolock) on ctm.IDTipoMenu = m.IDTipoMenu
	--	where p.FechaCreacion between @FechaIni and @FechaFin
	--		and isnull([p].Autorizado, 0) = 1
	--		and isnull([p].Cancelada, 0) = 0
	--		and (p.IDRestaurante = @IDRestaurante or isnull(@IDRestaurante, 0) = 0)
	--	group by r.Nombre, ctm.Nombre, dpa.PrecioUnidad	
	--) as info
	--order by Restaurante, TIPO, ltrim([ARTICULO/MENU])
GO
