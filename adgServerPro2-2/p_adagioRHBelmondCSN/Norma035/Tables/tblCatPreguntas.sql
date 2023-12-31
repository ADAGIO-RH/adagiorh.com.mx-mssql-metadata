USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma035].[tblCatPreguntas](
	[IDPregunta] [int] IDENTITY(1,1) NOT NULL,
	[IDSeccion] [int] NULL,
	[Pregunta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RespuestaMaxima] [int] NOT NULL,
	[Puntos] [float] NOT NULL,
	[Estatus] [bit] NOT NULL,
	[UltimaActualizacion] [datetime] NOT NULL,
 CONSTRAINT [Pk_Norma035TblCatPreguntas_IDPregunta] PRIMARY KEY CLUSTERED 
(
	[IDPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
