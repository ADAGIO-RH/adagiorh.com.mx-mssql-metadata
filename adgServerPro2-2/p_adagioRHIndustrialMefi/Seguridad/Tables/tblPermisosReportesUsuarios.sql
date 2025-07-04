USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblPermisosReportesUsuarios](
	[IDPermisoReporteUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDReporteBasico] [int] NOT NULL,
	[Acceso] [bit] NULL,
	[PermisoPersonalizado] [bit] NULL,
 CONSTRAINT [Pk_SeguridadTblPermisosReportesUsuario_IDPermisoReporteUsuario] PRIMARY KEY CLUSTERED 
(
	[IDPermisoReporteUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios] ADD  CONSTRAINT [D_SeguridadTblPermisosReportesUsuarios_Acceso]  DEFAULT ((0)) FOR [Acceso]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios] ADD  CONSTRAINT [D_SeguridadTblPermisosReportesUsuarios_PermisoPersonalizado]  DEFAULT ((0)) FOR [PermisoPersonalizado]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblPermisosReportesPerfiles_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios] CHECK CONSTRAINT [Fk_SeguridadTblPermisosReportesPerfiles_SeguridadTblUsuarios_IDUsuario]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblPermisosReportesUsuarios_ReportesTblCatReportesBasicos_IDReporteBasico] FOREIGN KEY([IDReporteBasico])
REFERENCES [Reportes].[tblCatReportesBasicos] ([IDReporteBasico])
ON DELETE CASCADE
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios] CHECK CONSTRAINT [Fk_SeguridadTblPermisosReportesUsuarios_ReportesTblCatReportesBasicos_IDReporteBasico]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblPermisosReportesUsuarios_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios] CHECK CONSTRAINT [Fk_SeguridadTblPermisosReportesUsuarios_SeguridadTblUsuarios_IDUsuario]
GO
