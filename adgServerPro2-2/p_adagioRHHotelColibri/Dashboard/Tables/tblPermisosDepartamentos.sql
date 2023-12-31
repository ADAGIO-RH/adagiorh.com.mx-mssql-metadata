USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dashboard].[tblPermisosDepartamentos](
	[IDUsuario] [int] NOT NULL,
	[CodigoDepartamento] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[tblPermisosDepartamentos]  WITH CHECK ADD  CONSTRAINT [Fk_DashboardTblPermisosDepartamentos_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Dashboard].[tblPermisosDepartamentos] CHECK CONSTRAINT [Fk_DashboardTblPermisosDepartamentos_SeguridadTblUsuarios_IDUsuario]
GO
