USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[TBLCATDEPARTAMENTOS20200819](
	[IDDepartamento] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CuentaContable] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NULL,
	[JefeDepartamento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
