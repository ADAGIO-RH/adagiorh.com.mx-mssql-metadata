USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tempPreguntasIndicadores](
	[IDProyecto] [int] NULL,
	[Proyecto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDGrupo] [int] NULL,
	[Grupo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPregunta] [int] NULL,
	[Pregunta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Indicador] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IndicadarAdagioRH] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
