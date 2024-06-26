USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatalogosGenerales](
	[IDCatalogoGeneral] [int] NOT NULL,
	[IDTipoCatalogo] [int] NOT NULL,
	[Catalogo] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_AppTblCatalogosGenerales_IDCatalogoGeneral] PRIMARY KEY CLUSTERED 
(
	[IDCatalogoGeneral] ASC,
	[IDTipoCatalogo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblCatalogosGenerales]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblCatalogosGenerales_AppTblTiposCatalogosGenerales_IDCatalogoGeneral] FOREIGN KEY([IDTipoCatalogo])
REFERENCES [App].[TblTiposCatalogosGenerales] ([IDTipoCatalogo])
GO
ALTER TABLE [App].[tblCatalogosGenerales] CHECK CONSTRAINT [Fk_AppTblCatalogosGenerales_AppTblTiposCatalogosGenerales_IDCatalogoGeneral]
GO
