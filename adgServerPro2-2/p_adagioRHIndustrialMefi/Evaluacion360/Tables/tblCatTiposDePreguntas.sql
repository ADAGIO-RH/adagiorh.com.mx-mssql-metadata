USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatTiposDePreguntas](
	[IDTipoPregunta] [int] NOT NULL,
	[TipoPregunta] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TiempoEstimadoRespuesta] [int] NULL,
	[IDUnidadDeTiempo] [int] NULL,
	[IDTemplate] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTemplateEdicion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CssClass] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConfPregunta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Component] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ComponentEvaluacion] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[InputType] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluaciones360TblCatTiposDePreguntas_IDTipoPregunta] PRIMARY KEY CLUSTERED 
(
	[IDTipoPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_Evaluaciones360TblCatTiposDePreguntas_TipoPregunta] UNIQUE NONCLUSTERED 
(
	[TipoPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatTiposDePreguntas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluaciones360TblCatTiposDePreguntas_AppTblCatUnidadesDeTiempo_IDUnidadDeTiempo] FOREIGN KEY([IDUnidadDeTiempo])
REFERENCES [App].[tblCatUnidadesDeTiempo] ([IDUnidadDeTiempo])
GO
ALTER TABLE [Evaluacion360].[tblCatTiposDePreguntas] CHECK CONSTRAINT [Fk_Evaluaciones360TblCatTiposDePreguntas_AppTblCatUnidadesDeTiempo_IDUnidadDeTiempo]
GO
ALTER TABLE [Evaluacion360].[tblCatTiposDePreguntas]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360TblCatTiposPreguntas_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatTiposDePreguntas] CHECK CONSTRAINT [Chk_Evaluacion360TblCatTiposPreguntas_Traduccion]
GO
