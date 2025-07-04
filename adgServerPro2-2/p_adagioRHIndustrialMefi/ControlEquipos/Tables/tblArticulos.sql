USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblArticulos](
	[IDArticulo] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoArticulo] [int] NOT NULL,
	[IDMetodoDepreciacion] [int] NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TieneCaducidad] [bit] NOT NULL,
	[FechaAlta] [date] NULL,
	[UsoCompartido] [bit] NOT NULL,
	[Cantidad] [int] NULL,
	[Stock] [int] NULL,
	[FechaHoraUltimaActualizaciónStock] [datetime] NULL,
 CONSTRAINT [PK_ControlEquiposTblArticulos_IDArticulo] PRIMARY KEY CLUSTERED 
(
	[IDArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblArticulos] ADD  CONSTRAINT [DF_ControlEquiposTblArticulos_TieneCaducidad]  DEFAULT ((0)) FOR [TieneCaducidad]
GO
ALTER TABLE [ControlEquipos].[tblArticulos] ADD  CONSTRAINT [DF_ControlEquiposTblArticulos_UsoCompartido]  DEFAULT ((0)) FOR [UsoCompartido]
GO
ALTER TABLE [ControlEquipos].[tblArticulos]  WITH CHECK ADD  CONSTRAINT [FK_ControlEquiposTblArticulos_ControlEquiposTblCatTiposArticulos_IDTipoArticulo] FOREIGN KEY([IDTipoArticulo])
REFERENCES [ControlEquipos].[tblCatTiposArticulos] ([IDTipoArticulo])
GO
ALTER TABLE [ControlEquipos].[tblArticulos] CHECK CONSTRAINT [FK_ControlEquiposTblArticulos_ControlEquiposTblCatTiposArticulos_IDTipoArticulo]
GO
ALTER TABLE [ControlEquipos].[tblArticulos]  WITH CHECK ADD  CONSTRAINT [FK_ControlEquiposTblArticulos_ControlEquiposTblMetodoDepreciacion_IDMetodoDepreciacion] FOREIGN KEY([IDMetodoDepreciacion])
REFERENCES [ControlEquipos].[tblMetodoDepreciacion] ([IDMetodoDepreciacion])
GO
ALTER TABLE [ControlEquipos].[tblArticulos] CHECK CONSTRAINT [FK_ControlEquiposTblArticulos_ControlEquiposTblMetodoDepreciacion_IDMetodoDepreciacion]
GO
