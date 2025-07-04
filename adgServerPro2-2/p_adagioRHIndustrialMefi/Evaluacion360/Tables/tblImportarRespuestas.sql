USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblImportarRespuestas](
	[IDImportarRespuestas] [int] IDENTITY(1,1) NOT NULL,
	[IDProyectoSource] [int] NOT NULL,
	[IDProyectoTarget] [int] NOT NULL,
	[IDPreguntaSource] [int] NOT NULL,
	[IDPreguntaTarget] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_Evaluacion360TblImportarRespuestas_IDImportarRespuestas] PRIMARY KEY CLUSTERED 
(
	[IDImportarRespuestas] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas] ADD  CONSTRAINT [D_Evaluacion360TblImportarRespuestas_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_Evaluacion360TblCatPreguntas_IDPreguntaSource] FOREIGN KEY([IDPreguntaSource])
REFERENCES [Evaluacion360].[tblCatPreguntas] ([IDPregunta])
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas] CHECK CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_Evaluacion360TblCatPreguntas_IDPreguntaSource]
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_Evaluacion360TblCatPreguntas_IDPreguntaTarget] FOREIGN KEY([IDPreguntaTarget])
REFERENCES [Evaluacion360].[tblCatPreguntas] ([IDPregunta])
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas] CHECK CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_Evaluacion360TblCatPreguntas_IDPreguntaTarget]
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_Evaluacion360TblCatProyectos_IDProyectoSource] FOREIGN KEY([IDProyectoSource])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas] CHECK CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_Evaluacion360TblCatProyectos_IDProyectoSource]
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_Evaluacion360TblCatProyectos_IDProyectoTarget] FOREIGN KEY([IDProyectoTarget])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas] CHECK CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_Evaluacion360TblCatProyectos_IDProyectoTarget]
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Evaluacion360].[tblImportarRespuestas] CHECK CONSTRAINT [Fk_Evaluacion360TblImportarRespuestas_SeguridadTblUsuarios_IDUsuario]
GO
