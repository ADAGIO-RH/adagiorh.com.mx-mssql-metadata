USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Docs].[tblDetalleFiltrosDocumentosUsuarios](
	[IDDetalleFiltrosDocumentosUsuarios] [int] IDENTITY(1,1) NOT NULL,
	[IDDocumento] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ValorFiltro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCatFiltroDocumento] [int] NULL,
 CONSTRAINT [PK_DocstblDetalleFiltrosDocumentosUsuarios_IDDetalleFiltrosDocumentosUsuarios] PRIMARY KEY CLUSTERED 
(
	[IDDetalleFiltrosDocumentosUsuarios] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_DocstblDetalleFiltrosDocumentosUsuarios_IDDocumento_IDUsuario_Filtro] UNIQUE NONCLUSTERED 
(
	[IDUsuario] ASC,
	[IDDocumento] ASC,
	[Filtro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Docs].[tblDetalleFiltrosDocumentosUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_DocsTblCarpetasDocumentos_DocstblDetalleFiltrosDocumentosUsuarios_IDDocumento] FOREIGN KEY([IDDocumento])
REFERENCES [Docs].[tblCarpetasDocumentos] ([IDItem])
GO
ALTER TABLE [Docs].[tblDetalleFiltrosDocumentosUsuarios] CHECK CONSTRAINT [FK_DocsTblCarpetasDocumentos_DocstblDetalleFiltrosDocumentosUsuarios_IDDocumento]
GO
ALTER TABLE [Docs].[tblDetalleFiltrosDocumentosUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatTiposFiltros_DocstblDetalleFiltrosDocumentosUsuarios_Filtro] FOREIGN KEY([Filtro])
REFERENCES [Seguridad].[tblCatTiposFiltros] ([Filtro])
GO
ALTER TABLE [Docs].[tblDetalleFiltrosDocumentosUsuarios] CHECK CONSTRAINT [FK_SeguridadTblCatTiposFiltros_DocstblDetalleFiltrosDocumentosUsuarios_Filtro]
GO
ALTER TABLE [Docs].[tblDetalleFiltrosDocumentosUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_DocstblDetalleFiltrosDocumentosUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Docs].[tblDetalleFiltrosDocumentosUsuarios] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_DocstblDetalleFiltrosDocumentosUsuarios_IDUsuario]
GO
