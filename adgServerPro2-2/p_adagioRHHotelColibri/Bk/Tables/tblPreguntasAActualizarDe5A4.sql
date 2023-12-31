USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPreguntasAActualizarDe5A4](
	[IDProyecto] [int] NOT NULL,
	[Proyecto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDEmpleadoProyecto] [int] NOT NULL,
	[IDEvaluacionEmpleado] [int] NOT NULL,
	[Grupo] [varchar](254) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Pregunta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDRespuestaPregunta] [int] NULL,
	[IDPregunta] [int] NULL,
	[Respuesta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorFinal] [decimal](18, 2) NULL,
	[IDEscalaValoracionGrupo] [int] NULL,
	[IDGrupo] [int] NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Valor] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
