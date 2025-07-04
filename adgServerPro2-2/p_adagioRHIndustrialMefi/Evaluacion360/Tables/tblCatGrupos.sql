USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatGrupos](
	[IDGrupo] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoGrupo] [int] NOT NULL,
	[Nombre] [varchar](254) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCreacion] [datetime] NULL,
	[TipoReferencia] [int] NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[CopiadoDeIDGrupo] [int] NULL,
	[IDTipoPreguntaGrupo] [int] NULL,
	[TotalPreguntas] [decimal](10, 1) NULL,
	[MaximaCalificacionPosible] [decimal](10, 1) NULL,
	[CalificacionObtenida] [decimal](10, 1) NULL,
	[CalificacionMinimaObtenida] [decimal](10, 1) NULL,
	[CalificacionMaxinaObtenida] [decimal](10, 1) NULL,
	[Promedio] [decimal](10, 2) NULL,
	[Porcentaje] [decimal](10, 2) NULL,
	[IsDefault] [bit] NULL,
	[Peso] [decimal](10, 2) NULL,
	[RequerirComentario] [bit] NULL,
	[Comentario] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ComentarioTextoPlano] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoEvaluacion] [int] NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatGrupos_IDGrupo] PRIMARY KEY CLUSTERED 
(
	[IDGrupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Evaluacion360TblCatGrupos_TipoReferenciaIDReferenciaNombre] ON [Evaluacion360].[tblCatGrupos]
(
	[TipoReferencia] ASC,
	[IDReferencia] ASC
)
INCLUDE([Nombre]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Evaluacion360TblCatGrupos_TipoReferenciaNombreIDReferenciaPorcentaje] ON [Evaluacion360].[tblCatGrupos]
(
	[TipoReferencia] ASC
)
INCLUDE([Nombre],[IDReferencia],[Porcentaje]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos] ADD  CONSTRAINT [D_Evaluacion360TblCatGrupos_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos] ADD  CONSTRAINT [D_Evaluacion360TblCatGrupos_TipoReferencia]  DEFAULT ((0)) FOR [TipoReferencia]
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos] ADD  CONSTRAINT [D_Evaluacion360TblCatGrupos_IDReferencia]  DEFAULT ((0)) FOR [IDReferencia]
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos] ADD  CONSTRAINT [D_Evaluacion360TblCatGrupos_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos] ADD  CONSTRAINT [D_Evaluacion360TblCatGrupos_RequerirComentario]  DEFAULT ((0)) FOR [RequerirComentario]
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos] ADD  CONSTRAINT [D_Evaluacion360TblCatGrupos_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatGrupos_Evaluacion360TblCatTipoGrupo_IDTipoGrupo] FOREIGN KEY([IDTipoGrupo])
REFERENCES [Evaluacion360].[tblCatTipoGrupo] ([IDTipoGrupo])
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatGrupos_Evaluacion360TblCatTipoGrupo_IDTipoGrupo]
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatGrupos_Evaluacion360TblCatTiposEvaluaciones_IDTipoEvaluacion] FOREIGN KEY([IDTipoEvaluacion])
REFERENCES [Evaluacion360].[tblCatTiposEvaluaciones] ([IDTipoEvaluacion])
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatGrupos_Evaluacion360TblCatTiposEvaluaciones_IDTipoEvaluacion]
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatGrupos_Evaluacion360TblCatTiposPreguntasGrupos_IDTipoPreguntaGrupo] FOREIGN KEY([IDTipoPreguntaGrupo])
REFERENCES [Evaluacion360].[tblCatTiposPreguntasGrupos] ([IDTipoPreguntaGrupo])
GO
ALTER TABLE [Evaluacion360].[tblCatGrupos] CHECK CONSTRAINT [Fk_Evaluacion360TblCatGrupos_Evaluacion360TblCatTiposPreguntasGrupos_IDTipoPreguntaGrupo]
GO
