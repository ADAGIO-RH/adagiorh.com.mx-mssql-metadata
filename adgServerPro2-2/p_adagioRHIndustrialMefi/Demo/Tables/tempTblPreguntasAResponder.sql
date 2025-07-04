USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Demo].[tempTblPreguntasAResponder](
	[IDGrupo] [int] NOT NULL,
	[IDTipoGrupo] [int] NOT NULL,
	[TipoGrupo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Grupo] [varchar](254) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[DescripcionGrupo] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaCreacionStr] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoReferencia] [int] NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[CopiadoDeIDGrupo] [int] NOT NULL,
	[IDPregunta] [int] NOT NULL,
	[IDTipoPregunta] [int] NOT NULL,
	[Pregunta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[EsRequerida] [bit] NOT NULL,
	[Calificar] [bit] NOT NULL,
	[Box9] [bit] NOT NULL,
	[IDCategoriaPregunta] [int] NOT NULL,
	[CategoriaPregunta] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Completa] [bit] NULL,
	[Respuesta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Box9DesempenioActual] [int] NOT NULL,
	[Box9DesempenioFuturo] [int] NOT NULL,
	[GrupoEscala] [bit] NULL,
	[Box9EsRequerido] [bit] NOT NULL,
	[Comentario] [bit] NOT NULL,
	[ComentarioEsRequerido] [bit] NOT NULL,
	[TotalComentarios] [int] NULL,
	[Row] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
