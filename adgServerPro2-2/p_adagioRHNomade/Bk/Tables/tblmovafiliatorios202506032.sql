USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblmovafiliatorios202506032](
	[IDMovAfiliatorio] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoMovimiento] [int] NOT NULL,
	[FechaIMSS] [date] NULL,
	[FechaIDSE] [date] NULL,
	[IDRazonMovimiento] [int] NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[SalarioIntegrado] [decimal](18, 2) NULL,
	[SalarioVariable] [decimal](18, 2) NULL,
	[SalarioDiarioReal] [decimal](18, 2) NULL,
	[IDRegPatronal] [int] NULL,
	[RespetarAntiguedad] [bit] NULL,
	[FechaAntiguedad] [date] NULL,
	[IDTipoPrestacion] [int] NULL,
	[Comentario] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaUltimoDiaLaborado] [date] NULL,
	[IDTipoRazonMovimiento] [int] NULL
) ON [PRIMARY]
GO
