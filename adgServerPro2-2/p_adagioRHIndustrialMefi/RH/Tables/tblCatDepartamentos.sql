USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatDepartamentos](
	[IDDepartamento] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [App].[MDDescription] NULL,
	[CuentaContable] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NULL,
	[JefeDepartamento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_tblCatDepartamentos_IDDepartamento] PRIMARY KEY CLUSTERED 
(
	[IDDepartamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblCatDepartamentos_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatDepartamentos]  WITH CHECK ADD  CONSTRAINT [Chk_RHtblCatDepartamentos_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [RH].[tblCatDepartamentos] CHECK CONSTRAINT [Chk_RHtblCatDepartamentos_Traduccion]
GO
