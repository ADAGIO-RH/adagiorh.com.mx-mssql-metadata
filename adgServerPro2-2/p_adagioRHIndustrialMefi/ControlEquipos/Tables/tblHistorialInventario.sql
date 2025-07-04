USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblHistorialInventario](
	[IDHistorialInventario] [int] IDENTITY(1,1) NOT NULL,
	[IDArticulo] [int] NULL,
	[IDUsuario] [int] NULL,
	[Fecha] [date] NULL,
	[CantidadAnterior] [int] NULL,
	[CantidadActual] [int] NULL,
	[TipoMovimiento] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Razon] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDsDetalleArticulo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Cantidad] [int] NULL,
 CONSTRAINT [Pk_ControlEquiposTblHistorialInventario_IDHistorialInventario] PRIMARY KEY CLUSTERED 
(
	[IDHistorialInventario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblHistorialInventario]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblHistorialInventario_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [ControlEquipos].[tblHistorialInventario] CHECK CONSTRAINT [Fk_ControlEquiposTblHistorialInventario_SeguridadTblUsuarios_IDUsuario]
GO
