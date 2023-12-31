USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblcatclientesjulio2023](
	[IDCliente] [int] IDENTITY(1,1) NOT NULL,
	[GenerarNoNomina] [bit] NULL,
	[LongitudNoNomina] [int] NULL,
	[Prefijo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreComercial] [App].[XLName] NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PathReciboNomina] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PathReciboNominaNoTimbrado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
