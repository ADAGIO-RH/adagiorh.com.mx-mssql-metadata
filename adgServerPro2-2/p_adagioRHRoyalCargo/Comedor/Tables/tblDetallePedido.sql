USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblDetallePedido](
	[IDDetallePedido] [int] IDENTITY(1,1) NOT NULL,
	[IDPedido] [int] NOT NULL,
	[IDMenu] [int] NULL,
	[IDArticulo] [int] NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioUnidad] [money] NOT NULL,
	[PrecioExtra] [money] NOT NULL,
	[Total]  AS ([Cantidad]*[PrecioUnidad]+[PrecioExtra]),
 CONSTRAINT [Pk_ComedorTblDetallePedido_IDDetallePedido] PRIMARY KEY CLUSTERED 
(
	[IDDetallePedido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblDetallePedido] ADD  CONSTRAINT [D_ComedorTblDetallePedido_Cantidad]  DEFAULT ((1)) FOR [Cantidad]
GO
ALTER TABLE [Comedor].[tblDetallePedido] ADD  CONSTRAINT [D_ComedorTblDetallePedido_PrecioUnidad]  DEFAULT ((0)) FOR [PrecioUnidad]
GO
ALTER TABLE [Comedor].[tblDetallePedido] ADD  CONSTRAINT [D_ComedorTblDetallePedido_PrecioExtra]  DEFAULT ((0)) FOR [PrecioExtra]
GO
ALTER TABLE [Comedor].[tblDetallePedido]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedido_ComedorTblCatArticulos_IDArticulo] FOREIGN KEY([IDArticulo])
REFERENCES [Comedor].[tblCatArticulos] ([IDArticulo])
GO
ALTER TABLE [Comedor].[tblDetallePedido] CHECK CONSTRAINT [Fk_ComedorTblDetallePedido_ComedorTblCatArticulos_IDArticulo]
GO
ALTER TABLE [Comedor].[tblDetallePedido]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedido_ComedorTblCatMenus_IDMenu] FOREIGN KEY([IDMenu])
REFERENCES [Comedor].[tblCatMenus] ([IDMenu])
GO
ALTER TABLE [Comedor].[tblDetallePedido] CHECK CONSTRAINT [Fk_ComedorTblDetallePedido_ComedorTblCatMenus_IDMenu]
GO
ALTER TABLE [Comedor].[tblDetallePedido]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedido_ComedorTblPedidos_IDPedido] FOREIGN KEY([IDPedido])
REFERENCES [Comedor].[tblPedidos] ([IDPedido])
GO
ALTER TABLE [Comedor].[tblDetallePedido] CHECK CONSTRAINT [Fk_ComedorTblDetallePedido_ComedorTblPedidos_IDPedido]
GO
