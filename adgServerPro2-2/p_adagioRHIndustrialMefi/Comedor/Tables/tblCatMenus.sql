USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblCatMenus](
	[IDMenu] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoMenu] [int] NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PrecioCosto] [money] NULL,
	[PrecioEmpleado] [money] NULL,
	[PrecioPublico] [money] NULL,
	[DisponibilidadPorFecha] [bit] NULL,
	[FechaDisponibilidadInicio] [date] NULL,
	[FechaDisponibilidadFin] [date] NULL,
	[Disponible] [bit] NULL,
	[MenuPedido] [bit] NULL,
	[IDMenuOriginal] [int] NULL,
	[FechaHora] [datetime] NULL,
	[IdsRestaurantes] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MenuDelDia] [bit] NULL,
	[HistorialDisponibilidad] [bit] NULL,
 CONSTRAINT [Pk_ComedorTblCatMenus_IDMenu] PRIMARY KEY CLUSTERED 
(
	[IDMenu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblCatMenus] ADD  CONSTRAINT [D_ComedorTblCatMenus_PrecioCosto]  DEFAULT ((0.00)) FOR [PrecioCosto]
GO
ALTER TABLE [Comedor].[tblCatMenus] ADD  CONSTRAINT [D_ComedorTblCatMenus_PrecioEmpleado]  DEFAULT ((0.00)) FOR [PrecioEmpleado]
GO
ALTER TABLE [Comedor].[tblCatMenus] ADD  CONSTRAINT [D_ComedorTblCatMenus_PrecioPublico]  DEFAULT ((0.00)) FOR [PrecioPublico]
GO
ALTER TABLE [Comedor].[tblCatMenus] ADD  CONSTRAINT [D_ComedorTblCatMenus_DisponibilidadPorFecha]  DEFAULT ((0)) FOR [DisponibilidadPorFecha]
GO
ALTER TABLE [Comedor].[tblCatMenus] ADD  CONSTRAINT [D_ComedorTblCatMenus_Disponible]  DEFAULT ((0)) FOR [Disponible]
GO
ALTER TABLE [Comedor].[tblCatMenus] ADD  CONSTRAINT [D_ComedorTblCatMenus_MenuPedido]  DEFAULT ((0)) FOR [MenuPedido]
GO
ALTER TABLE [Comedor].[tblCatMenus] ADD  CONSTRAINT [D_ComedorTblCatMenus_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Comedor].[tblCatMenus] ADD  CONSTRAINT [D_ComedorTblCatMenus_MenuDelDia]  DEFAULT ((0)) FOR [MenuDelDia]
GO
ALTER TABLE [Comedor].[tblCatMenus] ADD  CONSTRAINT [D_ComedorTblCatMenus_HistorialDisponibilidad]  DEFAULT ((0)) FOR [HistorialDisponibilidad]
GO
ALTER TABLE [Comedor].[tblCatMenus]  WITH CHECK ADD  CONSTRAINT [Fk_ComedorTblCatMenus_ComedorTblCatTiposMenus_IDTipoMenu] FOREIGN KEY([IDTipoMenu])
REFERENCES [Comedor].[tblCatTiposMenus] ([IDTipoMenu])
GO
ALTER TABLE [Comedor].[tblCatMenus] CHECK CONSTRAINT [Fk_ComedorTblCatMenus_ComedorTblCatTiposMenus_IDTipoMenu]
GO
