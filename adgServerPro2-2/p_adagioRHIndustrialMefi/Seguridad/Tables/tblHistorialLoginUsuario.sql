USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblHistorialLoginUsuario](
	[IDHistorialLoginUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NULL,
	[IDZonaHoraria] [int] NULL,
	[Browser] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[GeoLocation] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaHora] [datetime] NULL,
	[LoginCorrecto] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblHistorialLoginUsuario]  WITH CHECK ADD  CONSTRAINT [Fk_seguridadtblHistorialLoginUsuario_SeguridadtblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblHistorialLoginUsuario] CHECK CONSTRAINT [Fk_seguridadtblHistorialLoginUsuario_SeguridadtblUsuarios_IDUsuario]
GO
