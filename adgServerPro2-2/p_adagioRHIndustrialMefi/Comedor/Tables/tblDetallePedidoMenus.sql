USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblDetallePedidoMenus](
	[IDDetallePedidoMenu] [int] IDENTITY(1,1) NOT NULL,
	[IDPedido] [int] NOT NULL,
	[IDMenu] [int] NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioUnidad] [money] NOT NULL,
	[PrecioExtra] [money] NOT NULL,
	[Total]  AS ([Cantidad]*[PrecioUnidad]+[PrecioExtra]),
	[Notas] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ComedorTblDetallePedidoMenus_IDDetallePedidoMenu] PRIMARY KEY CLUSTERED 
(
	[IDDetallePedidoMenu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenus] ADD  CONSTRAINT [D_ComedorTblDetallePedidoMenus_Cantidad]  DEFAULT ((1)) FOR [Cantidad]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenus] ADD  CONSTRAINT [D_ComedorTblDetallePedidoMenus_PrecioUnidad]  DEFAULT ((0)) FOR [PrecioUnidad]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenus] ADD  CONSTRAINT [D_ComedorTblDetallePedidoMenus_PrecioExtra]  DEFAULT ((0)) FOR [PrecioExtra]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenus]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedidoMenus_ComedorTblCatMenus_IDMenu] FOREIGN KEY([IDMenu])
REFERENCES [Comedor].[tblCatMenus] ([IDMenu])
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenus] CHECK CONSTRAINT [Fk_ComedorTblDetallePedidoMenus_ComedorTblCatMenus_IDMenu]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenus]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedidoMenus_ComedorTblPedidos_IDPedido] FOREIGN KEY([IDPedido])
REFERENCES [Comedor].[tblPedidos] ([IDPedido])
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenus] CHECK CONSTRAINT [Fk_ComedorTblDetallePedidoMenus_ComedorTblPedidos_IDPedido]
GO
