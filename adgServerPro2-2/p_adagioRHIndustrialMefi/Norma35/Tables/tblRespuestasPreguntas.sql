USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblRespuestasPreguntas](
	[IDRespuestaPregunta] [int] IDENTITY(1,1) NOT NULL,
	[IDCatPregunta] [int] NOT NULL,
	[Respuesta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaRespuesta] [datetime] NULL,
	[ValorFinal] [decimal](18, 2) NULL,
 CONSTRAINT [PK_Norma35tblRespuestasPreguntas_IDRespuestaPregunta] PRIMARY KEY CLUSTERED 
(
	[IDRespuestaPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblRespuestasPreguntas] ADD  CONSTRAINT [D_Norma3TblRespuestasPreguntas_ValorFinal]  DEFAULT ((0.00)) FOR [ValorFinal]
GO
ALTER TABLE [Norma35].[tblRespuestasPreguntas]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblCatPreguntas_Norma35TblRespuestasPreguntas_IDCatPregunta] FOREIGN KEY([IDCatPregunta])
REFERENCES [Norma35].[tblCatPreguntas] ([IDCatPregunta])
GO
ALTER TABLE [Norma35].[tblRespuestasPreguntas] CHECK CONSTRAINT [FK_Norma35TblCatPreguntas_Norma35TblRespuestasPreguntas_IDCatPregunta]
GO
