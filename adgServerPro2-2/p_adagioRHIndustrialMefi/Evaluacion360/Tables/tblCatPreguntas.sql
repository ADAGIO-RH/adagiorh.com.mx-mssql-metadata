USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatPreguntas](
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
	[Vista] [bit] NULL,
	[IDIndicador] [int] NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatPreguntas_IDPregunta] PRIMARY KEY CLUSTERED 
(
	[IDPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Evaluacion360TblCatPreguntas_IDGrupoDescripcion] ON [Evaluacion360].[tblCatPreguntas]
(
	[IDGrupo] ASC
)
INCLUDE([Descripcion]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] ADD  CONSTRAINT [D_Evaluacion360TblCatPreguntas_EsRequerida]  DEFAULT ((0)) FOR [EsRequerida]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] ADD  CONSTRAINT [D_Evaluacion360TblCatPreguntas_Calificar]  DEFAULT ((0)) FOR [Calificar]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] ADD  CONSTRAINT [D_Evaluacion360tblCatPreguntas_Box9]  DEFAULT ((0)) FOR [Box9]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] ADD  CONSTRAINT [D_Evaluacion360TblCatPreguntas_Box9EsRequerido]  DEFAULT ((0)) FOR [Box9EsRequerido]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] ADD  CONSTRAINT [D_Evaluacion360TblCatPreguntas_Comentario]  DEFAULT ((0)) FOR [Comentario]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] ADD  CONSTRAINT [D_Evaluacion360TblCatPreguntas_ComentarioEsRequerido]  DEFAULT ((0)) FOR [ComentarioEsRequerido]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] ADD  CONSTRAINT [D_Evaluacion360TblCatPreguntas_MaximaCalificacionPosible]  DEFAULT ((0.0)) FOR [MaximaCalificacionPosible]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatPreguntas_Evaluacion360TblCatCategoriasPreguntas_IDCategoriaPregunta] FOREIGN KEY([IDCategoriaPregunta])
REFERENCES [Evaluacion360].[tblCatCategoriasPreguntas] ([IDCategoriaPregunta])
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] CHECK CONSTRAINT [Fk_Evaluacion360TblCatPreguntas_Evaluacion360TblCatCategoriasPreguntas_IDCategoriaPregunta]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatPreguntas_Evaluacion360TblCatGrupos_IDGrupo] FOREIGN KEY([IDGrupo])
REFERENCES [Evaluacion360].[tblCatGrupos] ([IDGrupo])
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] CHECK CONSTRAINT [Fk_Evaluacion360TblCatPreguntas_Evaluacion360TblCatGrupos_IDGrupo]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatPreguntas_Evaluacion360TblCatIndicadores_IDIndicador] FOREIGN KEY([IDIndicador])
REFERENCES [Evaluacion360].[tblCatIndicadores] ([IDIndicador])
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] CHECK CONSTRAINT [Fk_Evaluacion360TblCatPreguntas_Evaluacion360TblCatIndicadores_IDIndicador]
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatPreguntas_Evaluacion360TblCatTiposDePreguntas_IDTipoPregunta] FOREIGN KEY([IDTipoPregunta])
REFERENCES [Evaluacion360].[tblCatTiposDePreguntas] ([IDTipoPregunta])
GO
ALTER TABLE [Evaluacion360].[tblCatPreguntas] CHECK CONSTRAINT [Fk_Evaluacion360TblCatPreguntas_Evaluacion360TblCatTiposDePreguntas_IDTipoPregunta]
GO
