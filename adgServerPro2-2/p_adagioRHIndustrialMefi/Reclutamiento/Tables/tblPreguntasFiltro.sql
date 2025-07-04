USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblPreguntasFiltro](
	[IDPreguntaFiltro] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoPreguntaFiltro] [int] NOT NULL,
	[Pregunta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Respuestas] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoReferencia] [int] NOT NULL,
	[IDReferencia] [int] NULL,
 CONSTRAINT [PK_ReclutamientoTblPreguntasFiltro_IDPreguntaFiltro] PRIMARY KEY CLUSTERED 
(
	[IDPreguntaFiltro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblPreguntasFiltro]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientoTblCatTipoPreguntaFiltro_ReclutamientoPreguntasFiltro] FOREIGN KEY([IDTipoPreguntaFiltro])
REFERENCES [Reclutamiento].[tblCatTipoPreguntaFiltro] ([IDTipoPreguntaFiltro])
GO
ALTER TABLE [Reclutamiento].[tblPreguntasFiltro] CHECK CONSTRAINT [FK_ReclutamientoTblCatTipoPreguntaFiltro_ReclutamientoPreguntasFiltro]
GO
