USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblContactosUsuariosTiposNotificaciones](
	[IDContactoUsuarioTipoNotificacion] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDTipoNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTemplateNotificacion] [int] NOT NULL,
	[IDCliente] [int] NOT NULL,
 CONSTRAINT [PK_tblContactosUsuariosTiposNotificaciones_IDContactoUsuarioTipoNotificacion] PRIMARY KEY CLUSTERED 
(
	[IDContactoUsuarioTipoNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblContactosUsuariosTiposNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_AppTblTemplateNotificaciones_tblContactosUsuariosTiposNotificaciones_IDTemplateNotificacion] FOREIGN KEY([IDTemplateNotificacion])
REFERENCES [App].[tblTemplateNotificaciones] ([IDTemplateNotificacion])
GO
ALTER TABLE [App].[tblContactosUsuariosTiposNotificaciones] CHECK CONSTRAINT [FK_AppTblTemplateNotificaciones_tblContactosUsuariosTiposNotificaciones_IDTemplateNotificacion]
GO
ALTER TABLE [App].[tblContactosUsuariosTiposNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_AppTblTiposNotificaciones_tblContactosUsuariosTiposNotificaciones_IDTipoNotificacion] FOREIGN KEY([IDTipoNotificacion])
REFERENCES [App].[tblTiposNotificaciones] ([IDTipoNotificacion])
GO
ALTER TABLE [App].[tblContactosUsuariosTiposNotificaciones] CHECK CONSTRAINT [FK_AppTblTiposNotificaciones_tblContactosUsuariosTiposNotificaciones_IDTipoNotificacion]
GO
ALTER TABLE [App].[tblContactosUsuariosTiposNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_tblContactosUsuariosTiposNotificaciones_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [App].[tblContactosUsuariosTiposNotificaciones] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_tblContactosUsuariosTiposNotificaciones_IDUsuario]
GO
