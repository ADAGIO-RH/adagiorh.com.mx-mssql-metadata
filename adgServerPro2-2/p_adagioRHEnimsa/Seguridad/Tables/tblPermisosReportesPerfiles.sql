USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblPermisosReportesPerfiles](
	[IDPermisoReportePerfil] [int] IDENTITY(1,1) NOT NULL,
	[IDPerfil] [int] NOT NULL,
	[IDItem] [int] NOT NULL,
	[Acceso] [bit] NULL,
 CONSTRAINT [Pk_SeguridadTblPermisosReportesPerfiles_IDPermisoReportePerfil] PRIMARY KEY CLUSTERED 
(
	[IDPermisoReportePerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesPerfiles] ADD  CONSTRAINT [D_SeguridadTblPermisosReportesPerfiles_Acceso]  DEFAULT ((0)) FOR [Acceso]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesPerfiles]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblPermisosReportesPerfiles_ReportesTblCatReportes_IDItem] FOREIGN KEY([IDItem])
REFERENCES [Reportes].[tblCatReportes] ([IDItem])
ON DELETE CASCADE
GO
ALTER TABLE [Seguridad].[tblPermisosReportesPerfiles] CHECK CONSTRAINT [Fk_SeguridadTblPermisosReportesPerfiles_ReportesTblCatReportes_IDItem]
GO
ALTER TABLE [Seguridad].[tblPermisosReportesPerfiles]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblPermisosReportesPerfiles_SeguridadTblCatPerfiles_IDPerfil] FOREIGN KEY([IDPerfil])
REFERENCES [Seguridad].[tblCatPerfiles] ([IDPerfil])
ON DELETE CASCADE
GO
ALTER TABLE [Seguridad].[tblPermisosReportesPerfiles] CHECK CONSTRAINT [Fk_SeguridadTblPermisosReportesPerfiles_SeguridadTblCatPerfiles_IDPerfil]
GO
