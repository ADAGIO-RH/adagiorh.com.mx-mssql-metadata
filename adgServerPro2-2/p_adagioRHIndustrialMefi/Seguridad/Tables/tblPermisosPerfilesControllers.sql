USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblPermisosPerfilesControllers](
	[IDPermisoPerfilController] [int] IDENTITY(1,1) NOT NULL,
	[IDPerfil] [int] NOT NULL,
	[IDController] [int] NOT NULL,
	[IDTipoPermiso] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_SeguridadTblPermisosPerfilesControllers_IDPermisoPerfilController] PRIMARY KEY CLUSTERED 
(
	[IDPermisoPerfilController] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblPermisosPerfilesControllers_IDController] ON [Seguridad].[tblPermisosPerfilesControllers]
(
	[IDController] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblPermisosPerfilesControllers_IDPerfil] ON [Seguridad].[tblPermisosPerfilesControllers]
(
	[IDPerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblPermisosPerfilesControllers_IDTipoPermiso] ON [Seguridad].[tblPermisosPerfilesControllers]
(
	[IDTipoPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblPermisosPerfilesControllers]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblCatControllers_SeguridadTblPermisosPerfilesControllers_IDController] FOREIGN KEY([IDController])
REFERENCES [App].[tblCatControllers] ([IDController])
GO
ALTER TABLE [Seguridad].[tblPermisosPerfilesControllers] CHECK CONSTRAINT [Fk_AppTblCatControllers_SeguridadTblPermisosPerfilesControllers_IDController]
GO
ALTER TABLE [Seguridad].[tblPermisosPerfilesControllers]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblCatTipoPermiso_SeguridadTblPermisosPerfilesControllers_IDTipoPermiso] FOREIGN KEY([IDTipoPermiso])
REFERENCES [App].[tblCatTipoPermiso] ([IDTipoPermiso])
GO
ALTER TABLE [Seguridad].[tblPermisosPerfilesControllers] CHECK CONSTRAINT [Fk_AppTblCatTipoPermiso_SeguridadTblPermisosPerfilesControllers_IDTipoPermiso]
GO
ALTER TABLE [Seguridad].[tblPermisosPerfilesControllers]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblCatPerfiles_SeguridadTblPermisosPerfilesControllers_IDPerfil] FOREIGN KEY([IDPerfil])
REFERENCES [Seguridad].[tblCatPerfiles] ([IDPerfil])
GO
ALTER TABLE [Seguridad].[tblPermisosPerfilesControllers] CHECK CONSTRAINT [Fk_SeguridadTblCatPerfiles_SeguridadTblPermisosPerfilesControllers_IDPerfil]
GO
