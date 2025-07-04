USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblDetallePedidoMenusArticulos](
	[IDDetallePedidoMenusArticulos] [int] IDENTITY(1,1) NOT NULL,
	[IDDetallePedidoMenu] [int] NOT NULL,
	[IDMenu] [int] NULL,
	[IDArticulo] [int] NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioUnidad] [money] NOT NULL,
	[PrecioExtra] [money] NOT NULL,
	[Total]  AS ([Cantidad]*[PrecioUnidad]+[PrecioExtra]),
	[IDOpcionArticulo] [int] NULL,
	[OpcionSeleccionada] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ComedorTblDetallePedidoMenusArticulos_IDDetallePedidoMenusArticulos] PRIMARY KEY CLUSTERED 
(
	[IDDetallePedidoMenusArticulos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenusArticulos] ADD  CONSTRAINT [D_ComedorTblDetallePedidoMenusArticulos_Cantidad]  DEFAULT ((1)) FOR [Cantidad]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenusArticulos] ADD  CONSTRAINT [D_ComedorTblDetallePedidoMenusArticulos_PrecioUnidad]  DEFAULT ((0)) FOR [PrecioUnidad]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenusArticulos] ADD  CONSTRAINT [D_ComedorTblDetallePedidoMenusArticulos_PrecioExtra]  DEFAULT ((0)) FOR [PrecioExtra]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenusArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedidoMenusArticulos_ComedorTblCatArticulos_IDArticulo] FOREIGN KEY([IDArticulo])
REFERENCES [Comedor].[tblCatArticulos] ([IDArticulo])
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenusArticulos] CHECK CONSTRAINT [Fk_ComedorTblDetallePedidoMenusArticulos_ComedorTblCatArticulos_IDArticulo]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenusArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedidoMenusArticulos_ComedorTblCatMenus_IDMenu] FOREIGN KEY([IDMenu])
REFERENCES [Comedor].[tblCatMenus] ([IDMenu])
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenusArticulos] CHECK CONSTRAINT [Fk_ComedorTblDetallePedidoMenusArticulos_ComedorTblCatMenus_IDMenu]
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenusArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetallePedidoMenusArticulos_ComedorTblDetallePedidoMenus_IDDetallePedidoMenu] FOREIGN KEY([IDDetallePedidoMenu])
REFERENCES [Comedor].[tblDetallePedidoMenus] ([IDDetallePedidoMenu])
GO
ALTER TABLE [Comedor].[tblDetallePedidoMenusArticulos] CHECK CONSTRAINT [Fk_ComedorTblDetallePedidoMenusArticulos_ComedorTblDetallePedidoMenus_IDDetallePedidoMenu]
GO
