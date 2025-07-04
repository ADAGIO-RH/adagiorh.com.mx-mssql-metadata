USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblConfiguracionCatalogos](
	[IDConfiguracion] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NULL,
	[IDCatalogo] [int] NOT NULL,
	[IDValue] [int] NULL,
	[Visible] [bit] NULL,
	[Habilitado] [bit] NULL,
	[IDUrl] [int] NULL,
 CONSTRAINT [PK_APPTblConfiguracionCatalogos_IDConfiguracion] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblConfiguracionCatalogos] ADD  DEFAULT ((1)) FOR [Visible]
GO
ALTER TABLE [App].[tblConfiguracionCatalogos] ADD  DEFAULT ((1)) FOR [Habilitado]
GO
ALTER TABLE [App].[tblConfiguracionCatalogos]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatCatalogos_AppTblConfiguracionCatalogos_IDCatalogo] FOREIGN KEY([IDCatalogo])
REFERENCES [App].[tblCatCatalogos] ([IDCatalogo])
GO
ALTER TABLE [App].[tblConfiguracionCatalogos] CHECK CONSTRAINT [FK_AppTblCatCatalogos_AppTblConfiguracionCatalogos_IDCatalogo]
GO
ALTER TABLE [App].[tblConfiguracionCatalogos]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatUrls_AppTblConfiguracionesCatalogos_IDUrl] FOREIGN KEY([IDUrl])
REFERENCES [App].[tblCatUrls] ([IDUrl])
GO
ALTER TABLE [App].[tblConfiguracionCatalogos] CHECK CONSTRAINT [FK_AppTblCatUrls_AppTblConfiguracionesCatalogos_IDUrl]
GO
ALTER TABLE [App].[tblConfiguracionCatalogos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_AppTblConfiguracionCatalogos_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [App].[tblConfiguracionCatalogos] CHECK CONSTRAINT [FK_RHTblCatClientes_AppTblConfiguracionCatalogos_IDCliente]
GO
