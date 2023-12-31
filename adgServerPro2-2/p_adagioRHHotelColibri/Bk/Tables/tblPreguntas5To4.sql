USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPreguntas5To4](
	[IDProyecto] [int] NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDGrupo] [int] NOT NULL,
	[IDTipoGrupo] [int] NOT NULL,
	[Grupo] [varchar](254) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TotalPreguntas] [decimal](10, 1) NULL,
	[MaximaCalificacionPosible] [decimal](10, 1) NULL,
	[CalificacionObtenida] [decimal](10, 1) NULL,
	[CalificacionMinimaObtenida] [decimal](10, 1) NULL,
	[CalificacionMaxinaObtenida] [decimal](10, 1) NULL,
	[Promedio] [decimal](10, 2) NULL,
	[Porcentaje] [decimal](10, 2) NULL,
	[IDPregunta] [int] NOT NULL,
	[IDTipoPregunta] [int] NOT NULL,
	[Pregunta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Respuesta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorFinal] [decimal](18, 2) NULL,
	[Indicador] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
