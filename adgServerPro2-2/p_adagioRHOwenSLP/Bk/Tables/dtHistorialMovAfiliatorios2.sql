USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[dtHistorialMovAfiliatorios2](
	[Fecha] [date] NULL,
	[ClaveEmpleado] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Codigo] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoRazon] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[SalarioIntegrado] [decimal](18, 2) NULL,
	[SalarioVariable] [decimal](18, 2) NULL,
	[SalarioDiarioReal] [decimal](18, 2) NULL,
	[RegPatronal] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIMSS] [date] NULL,
	[FechaIDSE] [date] NULL
) ON [PRIMARY]
GO
