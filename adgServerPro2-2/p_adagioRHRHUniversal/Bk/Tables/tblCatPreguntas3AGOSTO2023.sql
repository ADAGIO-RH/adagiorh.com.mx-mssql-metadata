USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatPreguntas3AGOSTO2023](
	[IDPregunta] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoPregunta] [int] NOT NULL,
	[IDGrupo] [int] NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[EsRequerida] [bit] NOT NULL,
	[Calificar] [bit] NOT NULL,
	[Box9] [bit] NOT NULL,
	[IDCategoriaPregunta] [int] NULL,
	[Box9EsRequerido] [bit] NULL,
	[Comentario] [bit] NULL,
	[ComentarioEsRequerido] [bit] NULL,
	[MaximaCalificacionPosible] [decimal](10, 1) NULL,
	[Vista] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
