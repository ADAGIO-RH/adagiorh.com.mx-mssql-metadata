USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dashboard].[tblPermisosEspeciales](
	[IDUsuario] [int] NOT NULL,
	[config] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[tblPermisosEspeciales]  WITH CHECK ADD  CONSTRAINT [Fk_DashboardTblPermisosEspeciales_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Dashboard].[tblPermisosEspeciales] CHECK CONSTRAINT [Fk_DashboardTblPermisosEspeciales_SeguridadTblUsuarios_IDUsuario]
GO
