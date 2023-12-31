USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblPermisosReportesUsuarios](
	[IDPermisoReporteUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDItem] [int] NOT NULL,
	[Acceso] [bit] NULL,
 CONSTRAINT [Pk_SeguridadTblPermisosReportesUsuario_IDPermisoReporteUsuario] PRIMARY KEY CLUSTERED 
(
	[IDPermisoReporteUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios] ADD  CONSTRAINT [D_SeguridadTblPermisosReportesUsuarios_Acceso]  DEFAULT ((0)) FOR [Acceso]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios]  WITH NOCHECK ADD  CONSTRAINT [Fk_SeguridadTblPermisosReportesPerfiles_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios] CHECK CONSTRAINT [Fk_SeguridadTblPermisosReportesPerfiles_SeguridadTblUsuarios_IDUsuario]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios]  WITH NOCHECK ADD  CONSTRAINT [Fk_SeguridadTblPermisosReportesUsuarios_ReportesTblCatReportes_IDItem] FOREIGN KEY([IDItem])
REFERENCES [Reportes].[tblCatReportes] ([IDItem])
ON DELETE CASCADE
GO
ALTER TABLE [Seguridad].[tblPermisosReportesUsuarios] CHECK CONSTRAINT [Fk_SeguridadTblPermisosReportesUsuarios_ReportesTblCatReportes_IDItem]
GO
