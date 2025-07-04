USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spBuscarDetalleComandaAImprimir](
	@IDPedido int
) as
	--declare 
	----	@IDPedido int = 15,
	--	@IDDetallePedidoMenu int = 15
	--;

	-- Tabla 1 DetallePedidosMenus
	select
		 dpm.IDDetallePedidoMenu
		,dpm.IDPedido
		,dpm.IDMenu
		,dpm.Nombre
		,dpm.Descripcion
		,dpm.Cantidad
		,dpm.PrecioUnidad
		,dpm.PrecioExtra
		,dpm.Total
		,dpm.Notas
	from [Comedor].[tblDetallePedidoMenus] dpm with (nolock)
	where dpm.IDPedido = @IDPedido

	-- Tabla 2 DetallePedidosMenusArticulos
	select
		 dpma.IDDetallePedidoMenusArticulos
		,dpma.IDDetallePedidoMenu
		,dpma.IDMenu
		,dpma.IDArticulo
		,dpma.Nombre
		,dpma.Descripcion
		,dpma.Cantidad
		,dpma.PrecioUnidad
		,dpma.PrecioExtra
		,dpma.Total
		,isnull(dpma.IDOpcionArticulo,0) as IDOpcionArticulo
		,dpma.OpcionSeleccionada
	from [Comedor].[tblDetallePedidoMenusArticulos] dpma with (nolock)
	where dpma.IDDetallePedidoMenu in (
		select IDDetallePedidoMenu
		from [Comedor].[tblDetallePedidoMenus] dpm with (nolock)
		where dpm.IDPedido = @IDPedido
	)

	-- Tabla 3 Articulos individuales
	select
		 dpa.IDDetallePedidoArticulos
		,dpa.IDPedido
		,dpa.IDArticulo
		,dpa.Nombre
		,dpa.Descripcion
		,dpa.Cantidad
		,dpa.PrecioUnidad
		,dpa.PrecioExtra
		,dpa.Total
		,isnull(dpa.IDOpcionArticulo,0) as IDOpcionArticulo
		,dpa.OpcionSeleccionada
		,dpa.Notas
	from [Comedor].[tblDetallePedidoArticulos] dpa with (nolock)
	where dpa.IDPedido = @IDPedido
GO
