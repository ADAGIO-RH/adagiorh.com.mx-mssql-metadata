USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Docs].[tblDocumentosFavoritos](
	[IDDocumentoFavorito] [int] IDENTITY(1,1) NOT NULL,
	[IDDocumento] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [PK_DocsTblDocumentosFavoritos_IDDocumentoFavorito] PRIMARY KEY CLUSTERED 
(
	[IDDocumentoFavorito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Docs].[tblDocumentosFavoritos]  WITH CHECK ADD  CONSTRAINT [FK_DocsTblCarpetasDocumentos_DocsTblDocumentosFavoritos_IDDocumento] FOREIGN KEY([IDDocumento])
REFERENCES [Docs].[tblCarpetasDocumentos] ([IDItem])
GO
ALTER TABLE [Docs].[tblDocumentosFavoritos] CHECK CONSTRAINT [FK_DocsTblCarpetasDocumentos_DocsTblDocumentosFavoritos_IDDocumento]
GO
ALTER TABLE [Docs].[tblDocumentosFavoritos]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_DocstblDocumentosFavoritos_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Docs].[tblDocumentosFavoritos] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_DocstblDocumentosFavoritos_IDUsuario]
GO
