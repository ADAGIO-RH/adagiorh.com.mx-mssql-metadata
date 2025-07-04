USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ControlEquipos].[tblUrlsDocumentosDetallesArticulos](
	[IDUrlDocumentos] [int] IDENTITY(1,1) NOT NULL,
	[IDDetalleArticulo] [int] NULL,
	[Url] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreDocumento] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ControlEquiposTblUrlsDocumentosDetallesArticulos_IDUrlDocumentos] PRIMARY KEY CLUSTERED 
(
	[IDUrlDocumentos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ControlEquipos].[tblUrlsDocumentosDetallesArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ControlEquiposTblUrlsDocumentosDetallesArticulos_ControlEquiposTblDetalleArticulos_IDDetalleArticulo] FOREIGN KEY([IDDetalleArticulo])
REFERENCES [ControlEquipos].[tblDetalleArticulos] ([IDDetalleArticulo])
ON DELETE CASCADE
GO
ALTER TABLE [ControlEquipos].[tblUrlsDocumentosDetallesArticulos] CHECK CONSTRAINT [Fk_ControlEquiposTblUrlsDocumentosDetallesArticulos_ControlEquiposTblDetalleArticulos_IDDetalleArticulo]
GO
