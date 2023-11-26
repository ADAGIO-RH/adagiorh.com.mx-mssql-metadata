USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatUrls](
	[IDUrl] [int] NOT NULL,
	[IDModulo] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[URL] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Tipo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoPermiso] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDController] [int] NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_AppTblCatUrls_IDUrl] PRIMARY KEY CLUSTERED 
(
	[IDUrl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_apptblCatUrls_IDController] ON [App].[tblCatUrls]
(
	[IDController] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_apptblCatUrls_IDModulo] ON [App].[tblCatUrls]
(
	[IDModulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_apptblCatUrls_IDTipoPermiso] ON [App].[tblCatUrls]
(
	[IDTipoPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_apptblCatUrls_Tipo] ON [App].[tblCatUrls]
(
	[Tipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_apptblCatUrls_URL] ON [App].[tblCatUrls]
(
	[URL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [App].[tblCatUrls]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatModulos_AppTblCatUrls_IDModulo] FOREIGN KEY([IDModulo])
REFERENCES [App].[tblCatModulos] ([IDModulo])
GO
ALTER TABLE [App].[tblCatUrls] CHECK CONSTRAINT [FK_AppTblCatModulos_AppTblCatUrls_IDModulo]
GO
ALTER TABLE [App].[tblCatUrls]  WITH CHECK ADD  CONSTRAINT [FK_appTblCatTipoPermiso_AppTblCatUrls_IDTipoPermiso] FOREIGN KEY([IDTipoPermiso])
REFERENCES [App].[tblCatTipoPermiso] ([IDTipoPermiso])
GO
ALTER TABLE [App].[tblCatUrls] CHECK CONSTRAINT [FK_appTblCatTipoPermiso_AppTblCatUrls_IDTipoPermiso]
GO
ALTER TABLE [App].[tblCatUrls]  WITH CHECK ADD  CONSTRAINT [FK_ApptblCatUrls_AppTblControllers_IDController] FOREIGN KEY([IDController])
REFERENCES [App].[tblCatControllers] ([IDController])
GO
ALTER TABLE [App].[tblCatUrls] CHECK CONSTRAINT [FK_ApptblCatUrls_AppTblControllers_IDController]
GO
