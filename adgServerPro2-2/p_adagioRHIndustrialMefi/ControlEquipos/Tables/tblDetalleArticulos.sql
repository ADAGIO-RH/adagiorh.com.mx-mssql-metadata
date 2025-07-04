USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblDetalleArticulos](
	[IDDetalleArticulo] [int] IDENTITY(1,1) NOT NULL,
	[IDArticulo] [int] NULL,
	[Etiqueta] [varchar](12) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaAlta] [date] NULL,
	[IDGenero] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Costo] [decimal](10, 2) NULL,
	[IDUnidadDeTiempo] [int] NULL,
	[IDCatTipoCaducidad] [int] NULL,
	[Tiempo] [int] NULL,
 CONSTRAINT [Pk_ControlEquiposTblDetalleArticulos_IDDetalleArticulo] PRIMARY KEY CLUSTERED 
(
	[IDDetalleArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblDetalleArticulos]  WITH CHECK ADD  CONSTRAINT [FK_ControlEquiposTblDetalleArticulos_AppTblCatUnidadesDeTiempo_IDUnidadDeTiempo] FOREIGN KEY([IDUnidadDeTiempo])
REFERENCES [App].[tblCatUnidadesDeTiempo] ([IDUnidadDeTiempo])
GO
ALTER TABLE [ControlEquipos].[tblDetalleArticulos] CHECK CONSTRAINT [FK_ControlEquiposTblDetalleArticulos_AppTblCatUnidadesDeTiempo_IDUnidadDeTiempo]
GO
ALTER TABLE [ControlEquipos].[tblDetalleArticulos]  WITH CHECK ADD  CONSTRAINT [FK_ControlEquiposTblDetalleArticulos_ControlEquiposTblArticulos_IDArticulo] FOREIGN KEY([IDArticulo])
REFERENCES [ControlEquipos].[tblArticulos] ([IDArticulo])
ON DELETE CASCADE
GO
ALTER TABLE [ControlEquipos].[tblDetalleArticulos] CHECK CONSTRAINT [FK_ControlEquiposTblDetalleArticulos_ControlEquiposTblArticulos_IDArticulo]
GO
ALTER TABLE [ControlEquipos].[tblDetalleArticulos]  WITH CHECK ADD  CONSTRAINT [FK_ControlEquiposTblDetalleArticulos_ControlEquiposTblCatTiposCaducidad_IDCatTipoCaducidad] FOREIGN KEY([IDCatTipoCaducidad])
REFERENCES [ControlEquipos].[tblCatTiposCaducidad] ([IDCatTipoCaducidad])
GO
ALTER TABLE [ControlEquipos].[tblDetalleArticulos] CHECK CONSTRAINT [FK_ControlEquiposTblDetalleArticulos_ControlEquiposTblCatTiposCaducidad_IDCatTipoCaducidad]
GO
ALTER TABLE [ControlEquipos].[tblDetalleArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblDetalleArticulos_RHTblCatGeneros_IDGenero] FOREIGN KEY([IDGenero])
REFERENCES [RH].[tblCatGeneros] ([IDGenero])
GO
ALTER TABLE [ControlEquipos].[tblDetalleArticulos] CHECK CONSTRAINT [Fk_ControlEquiposTblDetalleArticulos_RHTblCatGeneros_IDGenero]
GO
