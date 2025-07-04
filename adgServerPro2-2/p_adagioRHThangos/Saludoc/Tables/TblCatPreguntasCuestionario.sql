USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Saludoc].[TblCatPreguntasCuestionario](
	[IDCatPregunta] [int] NOT NULL,
	[IDCatCuestionario] [int] NOT NULL,
	[IDCatEscala] [int] NOT NULL,
	[Elemento] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Categoria] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Pregunta] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Orden] [int] NOT NULL,
	[ValorNomina] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_SaludocTblCatPreguntasCuestionario_IDCatPregunta] PRIMARY KEY CLUSTERED 
(
	[IDCatPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Saludoc].[TblCatPreguntasCuestionario]  WITH CHECK ADD  CONSTRAINT [FK_SaludocTblCatEscalas_SaludocTblCatPreguntasCuestionario_IDCatEscala] FOREIGN KEY([IDCatEscala])
REFERENCES [Saludoc].[tblCatEscalas] ([IDCatEscala])
GO
ALTER TABLE [Saludoc].[TblCatPreguntasCuestionario] CHECK CONSTRAINT [FK_SaludocTblCatEscalas_SaludocTblCatPreguntasCuestionario_IDCatEscala]
GO
ALTER TABLE [Saludoc].[TblCatPreguntasCuestionario]  WITH CHECK ADD  CONSTRAINT [FK_SaludocTblCuestionarios_SaludocTblCatPreguntasCuestionario_IDCatCuestionario] FOREIGN KEY([IDCatCuestionario])
REFERENCES [Saludoc].[TblCatCuestionarios] ([IDCatCuestionario])
GO
ALTER TABLE [Saludoc].[TblCatPreguntasCuestionario] CHECK CONSTRAINT [FK_SaludocTblCuestionarios_SaludocTblCatPreguntasCuestionario_IDCatCuestionario]
GO
