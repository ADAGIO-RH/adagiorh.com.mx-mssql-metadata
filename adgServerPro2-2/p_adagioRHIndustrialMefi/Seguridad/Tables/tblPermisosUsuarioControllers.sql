USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblPermisosUsuarioControllers](
	[IDPermisoUsuarioController] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDController] [int] NOT NULL,
	[IDTipoPermiso] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PermisoPersonalizado] [bit] NULL,
 CONSTRAINT [Pk_SeguridadTblPermisosUsuarioControllers_IDPermisoUsuarioController] PRIMARY KEY CLUSTERED 
(
	[IDPermisoUsuarioController] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadTblPermisosUsuarioControllers] ON [Seguridad].[tblPermisosUsuarioControllers]
(
	[IDUsuario] ASC
)
INCLUDE([IDController]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblPermisosUsuarioControllers] ADD  CONSTRAINT [DF_tblPermisosUsuarioControllers_PermisoPersonalziado]  DEFAULT ((0)) FOR [PermisoPersonalizado]
GO
ALTER TABLE [Seguridad].[tblPermisosUsuarioControllers]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblCatControllers_SeguridadTblPermisosUsuarioControllers_IDController] FOREIGN KEY([IDController])
REFERENCES [App].[tblCatControllers] ([IDController])
GO
ALTER TABLE [Seguridad].[tblPermisosUsuarioControllers] CHECK CONSTRAINT [Fk_AppTblCatControllers_SeguridadTblPermisosUsuarioControllers_IDController]
GO
ALTER TABLE [Seguridad].[tblPermisosUsuarioControllers]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblCatTipoPermiso_SeguridadTblPermisosUsuariosControllers_IDTipoPermiso] FOREIGN KEY([IDTipoPermiso])
REFERENCES [App].[tblCatTipoPermiso] ([IDTipoPermiso])
GO
ALTER TABLE [Seguridad].[tblPermisosUsuarioControllers] CHECK CONSTRAINT [Fk_AppTblCatTipoPermiso_SeguridadTblPermisosUsuariosControllers_IDTipoPermiso]
GO
ALTER TABLE [Seguridad].[tblPermisosUsuarioControllers]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblUsuarios_SeguridadTblPermisosUsuarioControllers_IDPerfil] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblPermisosUsuarioControllers] CHECK CONSTRAINT [Fk_SeguridadTblUsuarios_SeguridadTblPermisosUsuarioControllers_IDPerfil]
GO
