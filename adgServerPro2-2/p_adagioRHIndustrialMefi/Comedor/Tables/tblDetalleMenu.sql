USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblDetalleMenu](
	[IDDetalleMenu] [int] IDENTITY(1,1) NOT NULL,
	[IDMenu] [int] NOT NULL,
	[IDArticulo] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioExtra] [money] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_ComedorTblDetalleMenu_IDDetalleMenu] PRIMARY KEY CLUSTERED 
(
	[IDDetalleMenu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblDetalleMenu] ADD  CONSTRAINT [D_ComedorTblDetalleMenu_Cantidad]  DEFAULT ((0)) FOR [Cantidad]
GO
ALTER TABLE [Comedor].[tblDetalleMenu] ADD  CONSTRAINT [D_ComedorTblDetalleMenu_PrecioExtra]  DEFAULT ((0)) FOR [PrecioExtra]
GO
ALTER TABLE [Comedor].[tblDetalleMenu] ADD  CONSTRAINT [D_ComedorTblDetalleMenu_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Comedor].[tblDetalleMenu]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetalleMenu_ComedorTblCatArticulos_IDArticulo] FOREIGN KEY([IDArticulo])
REFERENCES [Comedor].[tblCatArticulos] ([IDArticulo])
ON DELETE CASCADE
GO
ALTER TABLE [Comedor].[tblDetalleMenu] CHECK CONSTRAINT [Fk_ComedorTblDetalleMenu_ComedorTblCatArticulos_IDArticulo]
GO
ALTER TABLE [Comedor].[tblDetalleMenu]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblDetalleMenu_ComedorTblCatMenus_IDMenu] FOREIGN KEY([IDMenu])
REFERENCES [Comedor].[tblCatMenus] ([IDMenu])
ON DELETE CASCADE
GO
ALTER TABLE [Comedor].[tblDetalleMenu] CHECK CONSTRAINT [Fk_ComedorTblDetalleMenu_ComedorTblCatMenus_IDMenu]
GO
