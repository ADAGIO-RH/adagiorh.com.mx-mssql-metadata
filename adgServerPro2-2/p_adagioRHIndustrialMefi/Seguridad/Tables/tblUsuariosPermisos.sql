USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblUsuariosPermisos](
	[IDUsuarioPermiso] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDUrl] [int] NOT NULL,
 CONSTRAINT [PK_SeguridadTblUsuariosPermisos_IDUsuarioPermiso] PRIMARY KEY CLUSTERED 
(
	[IDUsuarioPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblUsuariosPermisos]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatUrls_SeguridadTblUsuariosPermisos_IDUrl] FOREIGN KEY([IDUrl])
REFERENCES [App].[tblCatUrls] ([IDUrl])
GO
ALTER TABLE [Seguridad].[tblUsuariosPermisos] CHECK CONSTRAINT [FK_AppTblCatUrls_SeguridadTblUsuariosPermisos_IDUrl]
GO
ALTER TABLE [Seguridad].[tblUsuariosPermisos]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_SeguridadTblUsuariosPermisos_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblUsuariosPermisos] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_SeguridadTblUsuariosPermisos_IDUsuario]
GO
