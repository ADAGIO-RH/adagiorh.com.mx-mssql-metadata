USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPermisosUsuarioControllers20231003T0204PM](
	[IDPermisoUsuarioController] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDController] [int] NOT NULL,
	[IDTipoPermiso] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PermisoPersonalizado] [bit] NULL
) ON [PRIMARY]
GO
