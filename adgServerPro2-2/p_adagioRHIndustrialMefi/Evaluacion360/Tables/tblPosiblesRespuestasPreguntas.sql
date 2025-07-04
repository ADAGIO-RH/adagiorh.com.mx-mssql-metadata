USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblPosiblesRespuestasPreguntas](
	[IDPosibleRespuesta] [int] IDENTITY(1,1) NOT NULL,
	[IDPregunta] [int] NOT NULL,
	[OpcionRespuesta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Valor] [int] NULL,
	[CreadoParaIDTipoPregunta] [int] NULL,
	[JSONData] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360TblPosiblesRespuestasPreguntas_IDPosibleRespuesta] PRIMARY KEY CLUSTERED 
(
	[IDPosibleRespuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblPosiblesRespuestasPreguntas] ADD  CONSTRAINT [D_Evaluacion360TblPosiblesRespuestasPreguntas_Valor]  DEFAULT ((0)) FOR [Valor]
GO
ALTER TABLE [Evaluacion360].[tblPosiblesRespuestasPreguntas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblPosiblesRespuestasPreguntas_Evaluacion360TblCatPreguntas_IDPregunta] FOREIGN KEY([IDPregunta])
REFERENCES [Evaluacion360].[tblCatPreguntas] ([IDPregunta])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblPosiblesRespuestasPreguntas] CHECK CONSTRAINT [Fk_Evaluacion360TblPosiblesRespuestasPreguntas_Evaluacion360TblCatPreguntas_IDPregunta]
GO
ALTER TABLE [Evaluacion360].[tblPosiblesRespuestasPreguntas]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360TblPosiblesRespuestasPreguntas_Data] CHECK  ((isjson([JSONData])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblPosiblesRespuestasPreguntas] CHECK CONSTRAINT [Chk_Evaluacion360TblPosiblesRespuestasPreguntas_Data]
GO
