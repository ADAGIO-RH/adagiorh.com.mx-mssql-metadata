USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblPosiblesRespuestasPreguntas](
	[IDPosibleRespuesta] [int] IDENTITY(1,1) NOT NULL,
	[IDPregunta] [int] NOT NULL,
	[OpcionRespuesta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Valor] [int] NULL,
 CONSTRAINT [PK_SaludTblPosiblesRespuestasPreguntas_IDPosibleRespuesta] PRIMARY KEY CLUSTERED 
(
	[IDPosibleRespuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblPosiblesRespuestasPreguntas]  WITH CHECK ADD  CONSTRAINT [FK_SaludTblPreguntas_SaludTblPosiblesRespuestas_IDPregunta] FOREIGN KEY([IDPregunta])
REFERENCES [Salud].[tblPreguntas] ([IDPregunta])
GO
ALTER TABLE [Salud].[tblPosiblesRespuestasPreguntas] CHECK CONSTRAINT [FK_SaludTblPreguntas_SaludTblPosiblesRespuestas_IDPregunta]
GO
