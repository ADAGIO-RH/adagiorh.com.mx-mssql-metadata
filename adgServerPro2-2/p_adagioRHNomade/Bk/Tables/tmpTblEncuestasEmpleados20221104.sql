USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tmpTblEncuestasEmpleados20221104](
	[IDEncuestaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEncuesta] [int] NOT NULL,
	[IDEmpleado] [int] NULL,
	[IDCatEstatus] [int] NOT NULL,
	[FechaAsignacion] [datetime] NULL,
	[FechaUltimaActualizacion] [datetime] NULL,
	[TotalPreguntas] [int] NULL,
	[TotalPreguntasContestadas] [int] NULL,
	[Resultado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RequiereAtencion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
