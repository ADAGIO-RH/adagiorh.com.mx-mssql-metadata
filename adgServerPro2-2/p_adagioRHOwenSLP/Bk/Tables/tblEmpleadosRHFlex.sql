USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblEmpleadosRHFlex](
	[CodigoEmpleado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Numero] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CodigoCliente] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[NominaRHFlex] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Clave_Trabajador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RFC] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURP] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IMSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SegundoNombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Paterno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Materno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NULL,
	[IDRegPatronal] [int] NULL,
	[RegistroPatronal] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpresa] [int] NULL,
	[NombreComercial] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[BDRHFLEX] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
