USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tempEvaluacionesEmpleadosEliminadas3602022](
	[IDEmpleadoProyecto] [int] NULL,
	[IDEvaluacionEmpleado] [int] NULL,
	[ClaveEmpleado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Colaborador] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClaveEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Evaluador] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoRelacion] [int] NULL,
	[Relacion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CLAVE EMPLEADO] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NULL,
	[CLAVE EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEvaluador] [int] NULL,
	[RELACIÓN DEL EVALUADOR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[REQUERIDO] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CORRECTO] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
