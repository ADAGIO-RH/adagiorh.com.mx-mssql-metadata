USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPermisosReportesUsuarios23082022](
	[IDPermisoReporteUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDReporteBasico] [int] NOT NULL,
	[Acceso] [bit] NULL,
	[PermisoPersonalizado] [bit] NULL
) ON [PRIMARY]
GO
