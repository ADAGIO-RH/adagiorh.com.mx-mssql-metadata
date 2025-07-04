USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblCatArticulos](
	[IDArticulo] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoArticulo] [int] NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PrecioCosto] [money] NULL,
	[PrecioEmpleado] [money] NULL,
	[PrecioPublico] [money] NULL,
	[HoraDisponibilidadInicio] [time](7) NULL,
	[HoraDisponibilidadFin] [time](7) NULL,
	[VentaIndividual] [bit] NULL,
	[Disponible] [bit] NULL,
	[ArticuloPedido] [bit] NULL,
	[IDArticuloOriginal] [int] NULL,
	[FechaHora] [datetime] NULL,
	[IdsRestaurantes] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCategoria] [int] NULL,
 CONSTRAINT [Pk_ComedorTblCatArticulos_IDArticulo] PRIMARY KEY CLUSTERED 
(
	[IDArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblCatArticulos] ADD  CONSTRAINT [D_ComedorTblCatArticulos_PrecioCosto]  DEFAULT ((0.00)) FOR [PrecioCosto]
GO
ALTER TABLE [Comedor].[tblCatArticulos] ADD  CONSTRAINT [D_ComedorTblCatArticulos_PrecioEmpleado]  DEFAULT ((0.00)) FOR [PrecioEmpleado]
GO
ALTER TABLE [Comedor].[tblCatArticulos] ADD  CONSTRAINT [D_ComedorTblCatArticulos_PrecioPublico]  DEFAULT ((0.00)) FOR [PrecioPublico]
GO
ALTER TABLE [Comedor].[tblCatArticulos] ADD  CONSTRAINT [D_ComedorTblCatArticulos_HoraDisponibilidadInicio]  DEFAULT ('00:00') FOR [HoraDisponibilidadInicio]
GO
ALTER TABLE [Comedor].[tblCatArticulos] ADD  CONSTRAINT [D_ComedorTblCatArticulos_HoraDisponibilidadFin]  DEFAULT ('00:00') FOR [HoraDisponibilidadFin]
GO
ALTER TABLE [Comedor].[tblCatArticulos] ADD  CONSTRAINT [D_ComedorTblCatArticulos_VentaIndividual]  DEFAULT ((0)) FOR [VentaIndividual]
GO
ALTER TABLE [Comedor].[tblCatArticulos] ADD  CONSTRAINT [D_ComedorTblCatArticulos_Disponible]  DEFAULT ((0)) FOR [Disponible]
GO
ALTER TABLE [Comedor].[tblCatArticulos] ADD  CONSTRAINT [D_ComedorTblCatArticulos_ArticuloPedido]  DEFAULT ((0)) FOR [ArticuloPedido]
GO
ALTER TABLE [Comedor].[tblCatArticulos] ADD  CONSTRAINT [D_ComedorTblCatArticulos_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Comedor].[tblCatArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblCatArticulos_ComedorTblCatCategorias_IDCategoria] FOREIGN KEY([IDCategoria])
REFERENCES [Comedor].[TblCatCategorias] ([IDCategoria])
GO
ALTER TABLE [Comedor].[tblCatArticulos] CHECK CONSTRAINT [Fk_ComedorTblCatArticulos_ComedorTblCatCategorias_IDCategoria]
GO
ALTER TABLE [Comedor].[tblCatArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblCatArticulos_ComedorTblCatTiposArticulos_IDTipoArticulo] FOREIGN KEY([IDTipoArticulo])
REFERENCES [Comedor].[tblCatTiposArticulos] ([IDTipoArticulo])
GO
ALTER TABLE [Comedor].[tblCatArticulos] CHECK CONSTRAINT [Fk_ComedorTblCatArticulos_ComedorTblCatTiposArticulos_IDTipoArticulo]
GO
