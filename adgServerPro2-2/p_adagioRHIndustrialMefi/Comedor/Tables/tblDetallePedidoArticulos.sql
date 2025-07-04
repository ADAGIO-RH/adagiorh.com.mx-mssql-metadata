USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblDetallePedidoArticulos](
	[IDDetallePedidoArticulos] [int] IDENTITY(1,1) NOT NULL,
	[IDPedido] [int] NOT NULL,
	[IDArticulo] [int] NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioUnidad] [money] NOT NULL,
	[PrecioExtra] [money] NOT NULL,
	[Total]  AS ([Cantidad]*[PrecioUnidad]+[PrecioExtra]),
	[IDOpcionArticulo] [int] NULL,
	[OpcionSeleccionada] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Notas] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ComedorTblDetallePedidoArticulos_IDDetallePedidoMenu] PRIMARY KEY CLUSTERED 
(
	[IDDetallePedidoArticulos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblDetallePedidoArticulos] ADD  CONSTRAINT [D_ComedorTblDetallePedidoArticulos_Cantidad]  DEFAULT ((1)) FOR [Cantidad]
GO
ALTER TABLE [Comedor].[tblDetallePedidoArticulos] ADD  CONSTRAINT [D_ComedorTblDetallePedidoArticulos_PrecioUnidad]  DEFAULT ((0)) FOR [PrecioUnidad]
GO
ALTER TABLE [Comedor].[tblDetallePedidoArticulos] ADD  CONSTRAINT [D_ComedorTblDetallePedidoArticulos_PrecioExtra]  DEFAULT ((0)) FOR [PrecioExtra]
GO
ALTER TABLE [Comedor].[tblDetallePedidoArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedidoArticulos_ComedorTblCatArticulos_IDArticulo] FOREIGN KEY([IDArticulo])
REFERENCES [Comedor].[tblCatArticulos] ([IDArticulo])
GO
ALTER TABLE [Comedor].[tblDetallePedidoArticulos] CHECK CONSTRAINT [Fk_ComedorTblDetallePedidoArticulos_ComedorTblCatArticulos_IDArticulo]
GO
ALTER TABLE [Comedor].[tblDetallePedidoArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedidoArticulos_ComedorTblPedidos_IDPedido] FOREIGN KEY([IDPedido])
REFERENCES [Comedor].[tblPedidos] ([IDPedido])
GO
ALTER TABLE [Comedor].[tblDetallePedidoArticulos] CHECK CONSTRAINT [Fk_ComedorTblDetallePedidoArticulos_ComedorTblPedidos_IDPedido]
GO
