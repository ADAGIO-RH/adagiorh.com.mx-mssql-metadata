USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblHistorialPasswordsUsuarios](
	[IDPasswordsUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NULL,
	[Password] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UltimaFechaActualizacion] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblHistorialPasswordsUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_seguridadtblPasswordsUsuarios_SeguridadtblUsuarioss_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblHistorialPasswordsUsuarios] CHECK CONSTRAINT [Fk_seguridadtblPasswordsUsuarios_SeguridadtblUsuarioss_IDUsuario]
GO
