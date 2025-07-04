USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblQuienResponderaPregunta](
	[IDQuienResponderaPregunta] [int] IDENTITY(1,1) NOT NULL,
	[IDPregunta] [int] NOT NULL,
	[IDTipoRelacion] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblQuienResponderaPregunta_IDQuienResponderaPregunta] PRIMARY KEY CLUSTERED 
(
	[IDQuienResponderaPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblQuienResponderaPregunta]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblQuienResponderaPregunta_Evaluacion360TblCatPreguntas_IDPregunta] FOREIGN KEY([IDPregunta])
REFERENCES [Evaluacion360].[tblCatPreguntas] ([IDPregunta])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblQuienResponderaPregunta] CHECK CONSTRAINT [Fk_Evaluacion360TblQuienResponderaPregunta_Evaluacion360TblCatPreguntas_IDPregunta]
GO
ALTER TABLE [Evaluacion360].[tblQuienResponderaPregunta]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblQuienResponderaPregunta_Evaluacion360TblCatTiposRelaciones_IDTipoRelacion] FOREIGN KEY([IDTipoRelacion])
REFERENCES [Evaluacion360].[tblCatTiposRelaciones] ([IDTipoRelacion])
GO
ALTER TABLE [Evaluacion360].[tblQuienResponderaPregunta] CHECK CONSTRAINT [Fk_Evaluacion360TblQuienResponderaPregunta_Evaluacion360TblCatTiposRelaciones_IDTipoRelacion]
GO
