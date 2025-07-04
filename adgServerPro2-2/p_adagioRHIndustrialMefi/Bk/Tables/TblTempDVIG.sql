USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[TblTempDVIG](
	[IDEmpleado] [int] NULL,
	[Fecha] [date] NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DiasVigencia] [decimal](18, 4) NULL,
	[FechaInicioPeriodo] [date] NULL,
	[FechaFinPeriodo] [date] NULL,
	[IDPeriodo] [int] NULL,
	[Count] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL
) ON [PRIMARY]
GO
