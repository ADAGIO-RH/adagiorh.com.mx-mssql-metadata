USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblPermisosEspecialesPerfiles](
	[IDPermisoEspecialPerfil] [int] IDENTITY(1,1) NOT NULL,
	[IDPermiso] [int] NOT NULL,
	[IDPerfil] [int] NOT NULL,
 CONSTRAINT [PK_SeguridadTblPermisosEspecialesPerfiles_IDPermisoEspecialPerfil] PRIMARY KEY CLUSTERED 
(
	[IDPermisoEspecialPerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblPermisosEspecialesPerfiles_IDPerfil] ON [Seguridad].[tblPermisosEspecialesPerfiles]
(
	[IDPerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblPermisosEspecialesPerfiles_IDPermiso] ON [Seguridad].[tblPermisosEspecialesPerfiles]
(
	[IDPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblPermisosEspecialesPerfiles]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatPermisosEspeciales_SeguridadTblPermisosEspecialesPerfiles_IDPermiso] FOREIGN KEY([IDPermiso])
REFERENCES [App].[tblCatPermisosEspeciales] ([IDPermiso])
GO
ALTER TABLE [Seguridad].[tblPermisosEspecialesPerfiles] CHECK CONSTRAINT [FK_AppTblCatPermisosEspeciales_SeguridadTblPermisosEspecialesPerfiles_IDPermiso]
GO
ALTER TABLE [Seguridad].[tblPermisosEspecialesPerfiles]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatPerfiles_SeguridadTblPermisosEspecialesPerfiles_IDPerfil] FOREIGN KEY([IDPerfil])
REFERENCES [Seguridad].[tblCatPerfiles] ([IDPerfil])
GO
ALTER TABLE [Seguridad].[tblPermisosEspecialesPerfiles] CHECK CONSTRAINT [FK_SeguridadTblCatPerfiles_SeguridadTblPermisosEspecialesPerfiles_IDPerfil]
GO
