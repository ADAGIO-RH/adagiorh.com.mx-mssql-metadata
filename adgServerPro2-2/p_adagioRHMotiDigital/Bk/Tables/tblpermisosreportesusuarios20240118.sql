USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblpermisosreportesusuarios20240118](
	[IDPermisoReporteUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDReporteBasico] [int] NOT NULL,
	[Acceso] [bit] NULL,
	[PermisoPersonalizado] [bit] NULL
) ON [PRIMARY]
GO
