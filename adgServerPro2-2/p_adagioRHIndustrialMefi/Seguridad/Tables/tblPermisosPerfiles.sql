USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblPermisosPerfiles](
	[IDPermisoPerfil] [int] IDENTITY(1,1) NOT NULL,
	[IDPerfil] [int] NOT NULL,
	[IDUrl] [int] NOT NULL,
 CONSTRAINT [PK_SeguridadTblPermisosPerfiles_IDPermisoPerfil] PRIMARY KEY CLUSTERED 
(
	[IDPermisoPerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblPermisosPerfiles_IDPerfil] ON [Seguridad].[tblPermisosPerfiles]
(
	[IDPerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblPermisosPerfiles_IDUrl] ON [Seguridad].[tblPermisosPerfiles]
(
	[IDUrl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblPermisosPerfiles]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatUrls_SeguridadtblPermisosPerfiles_IDUrl] FOREIGN KEY([IDUrl])
REFERENCES [App].[tblCatUrls] ([IDUrl])
GO
ALTER TABLE [Seguridad].[tblPermisosPerfiles] CHECK CONSTRAINT [FK_AppTblCatUrls_SeguridadtblPermisosPerfiles_IDUrl]
GO
ALTER TABLE [Seguridad].[tblPermisosPerfiles]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatPerfiles_SeguridadtblPermisosPerfiles_IDPerfil] FOREIGN KEY([IDPerfil])
REFERENCES [Seguridad].[tblCatPerfiles] ([IDPerfil])
GO
ALTER TABLE [Seguridad].[tblPermisosPerfiles] CHECK CONSTRAINT [FK_SeguridadTblCatPerfiles_SeguridadtblPermisosPerfiles_IDPerfil]
GO
