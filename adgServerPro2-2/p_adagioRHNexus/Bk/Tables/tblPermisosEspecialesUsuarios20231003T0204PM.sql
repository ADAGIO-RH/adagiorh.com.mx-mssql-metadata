USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPermisosEspecialesUsuarios20231003T0204PM](
	[IDPermisoEspecialUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDPermiso] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[PermisoPersonalizado] [bit] NULL
) ON [PRIMARY]
GO
