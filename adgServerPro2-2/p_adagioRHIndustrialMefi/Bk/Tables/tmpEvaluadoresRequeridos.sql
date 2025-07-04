USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tmpEvaluadoresRequeridos](
	[IDEmpleadoProyecto] [int] NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Colaborador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEvaluacionEmpleado] [int] NOT NULL,
	[IDTipoRelacion] [int] NOT NULL,
	[Relacion] [varchar](255) COLLATE Latin1_General_CI_AI NULL,
	[IDEvaluador] [int] NOT NULL,
	[Evaluador] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Requerido] [bit] NULL
) ON [PRIMARY]
GO
