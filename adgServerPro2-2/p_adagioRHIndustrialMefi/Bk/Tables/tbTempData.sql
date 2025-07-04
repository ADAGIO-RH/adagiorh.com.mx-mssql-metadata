USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tbTempData](
	[CLAVE] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NOMBRE] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RAZON_SOCIAL] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[COD. SUCURSAL] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SUCURSAL] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[COD. DEPARTAMENTO] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DEPARTAMENTO] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[COD. PUESTO] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PUESTO] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[COD. DIVISION] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DIVISION] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[COD. CENTRO COSTO] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CENTRO_COSTO] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[VIGENTE HOY] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Concepto] [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OrdenCalculo] [int] NOT NULL,
	[UUID] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Estatus_Timbrado] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Fecha_Timbrado] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ImporteTotal1] [decimal](38, 2) NULL
) ON [PRIMARY]
GO
