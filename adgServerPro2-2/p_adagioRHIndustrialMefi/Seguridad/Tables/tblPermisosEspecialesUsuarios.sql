USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblPermisosEspecialesUsuarios](
	[IDPermisoEspecialUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDPermiso] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[PermisoPersonalizado] [bit] NULL,
 CONSTRAINT [PK_SeguridadTblPermisosEspecialesUsuarios_IDPermisoEspecialUsuario] PRIMARY KEY CLUSTERED 
(
	[IDPermisoEspecialUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblPermisosEspecialesUsuarios_IDPermiso] ON [Seguridad].[tblPermisosEspecialesUsuarios]
(
	[IDPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblPermisosEspecialesUsuarios_IDUsuario] ON [Seguridad].[tblPermisosEspecialesUsuarios]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblPermisosEspecialesUsuarios] ADD  CONSTRAINT [DF_tblPermisosEspecialesUsuarios_PermisoPersonalizado]  DEFAULT ((0)) FOR [PermisoPersonalizado]
GO
ALTER TABLE [Seguridad].[tblPermisosEspecialesUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatPermisosEspeciales_SeguridadTblPermisosEspecialesUsuarios_IDPermiso] FOREIGN KEY([IDPermiso])
REFERENCES [App].[tblCatPermisosEspeciales] ([IDPermiso])
GO
ALTER TABLE [Seguridad].[tblPermisosEspecialesUsuarios] CHECK CONSTRAINT [FK_AppTblCatPermisosEspeciales_SeguridadTblPermisosEspecialesUsuarios_IDPermiso]
GO
ALTER TABLE [Seguridad].[tblPermisosEspecialesUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatUsuarios_SeguridadTblPermisosEspecialesUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblPermisosEspecialesUsuarios] CHECK CONSTRAINT [FK_SeguridadTblCatUsuarios_SeguridadTblPermisosEspecialesUsuarios_IDUsuario]
GO
