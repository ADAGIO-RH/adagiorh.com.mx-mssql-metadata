USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spBuscarDetallePedido]
(@IDPedido int 
 ,@IDUsuario int
 )
as

select 
	tp.IDPedido as [IDPedido],
	Numero  as [NUMERO]
	,dpm.Nombre AS [ITEM] 
	,isnull(dpm.Notas,'') AS [NOTA]
	,(dpm.Cantidad) AS [CANTIDAD]
	,(dpm.PrecioUnidad+dpm.PrecioExtra) AS [PRECIO]
	,(dpm.Total) AS [TOTAL]

	from [Comedor].[tblPedidos] tp
	join [Comedor].[tblDetallePedidoMenus] dpm on  tp.IDPedido = dpm.IDPedido
	where tp.IDPedido = @IDPedido
GO
