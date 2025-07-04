USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Docs].[tblFiltrosDocumentos](
	[IDFiltrosDocumentos] [int] IDENTITY(1,1) NOT NULL,
	[IDDocumento] [int] NOT NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCatFiltroDocumento] [int] NOT NULL,
 CONSTRAINT [PK_DocstblFiltrosDocumentos_IDFiltrosDocumentos] PRIMARY KEY CLUSTERED 
(
	[IDFiltrosDocumentos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Docs].[tblFiltrosDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_DocstblCarpetasDocumentos_DocstblFiltrosDocumentos_IDDocumento] FOREIGN KEY([IDDocumento])
REFERENCES [Docs].[tblCarpetasDocumentos] ([IDItem])
GO
ALTER TABLE [Docs].[tblFiltrosDocumentos] CHECK CONSTRAINT [FK_DocstblCarpetasDocumentos_DocstblFiltrosDocumentos_IDDocumento]
GO
ALTER TABLE [Docs].[tblFiltrosDocumentos]  WITH CHECK ADD  CONSTRAINT [Fk_DocstblCatFiltrosDocumentos_DocstblFiltrosDocumentos_IDCatFiltroDocumento] FOREIGN KEY([IDCatFiltroDocumento])
REFERENCES [Docs].[tblCatFiltrosDocumentos] ([IDCatFiltroDocumento])
ON DELETE CASCADE
GO
ALTER TABLE [Docs].[tblFiltrosDocumentos] CHECK CONSTRAINT [Fk_DocstblCatFiltrosDocumentos_DocstblFiltrosDocumentos_IDCatFiltroDocumento]
GO
ALTER TABLE [Docs].[tblFiltrosDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatTipoFiltros_DocstblFiltrosDocumentos_Filtro] FOREIGN KEY([Filtro])
REFERENCES [Seguridad].[tblCatTiposFiltros] ([Filtro])
GO
ALTER TABLE [Docs].[tblFiltrosDocumentos] CHECK CONSTRAINT [FK_SeguridadTblCatTipoFiltros_DocstblFiltrosDocumentos_Filtro]
GO
