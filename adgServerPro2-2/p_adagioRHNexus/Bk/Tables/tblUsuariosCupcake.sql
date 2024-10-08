USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblUsuariosCupcake](
	[IDUsuario] [int] IDENTITY(1,1) NOT NULL,
	[Cuenta] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Password] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPreferencia] [int] NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Apellido] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Email] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Activo] [bit] NULL,
	[IDPerfil] [int] NOT NULL,
	[IDEmpleado] [int] NULL,
	[Sexo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Supervisor] [bit] NULL
) ON [PRIMARY]
GO
