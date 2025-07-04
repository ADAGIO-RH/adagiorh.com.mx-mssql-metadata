USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatEstatus](
	[IDEstatus] [int] NOT NULL,
	[IDTipoEstatus] [int] NOT NULL,
	[Estatus] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Color] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Icono] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TotalEvaluaciones] [int] NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatEstatus_IDEstatus] PRIMARY KEY CLUSTERED 
(
	[IDEstatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatEstatus]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblCatEstatus_Evaluacion360TblCatTiposEstatus_IDTipoEstatus] FOREIGN KEY([IDTipoEstatus])
REFERENCES [Evaluacion360].[tblCatTiposEstatus] ([IDTipoEstatus])
GO
ALTER TABLE [Evaluacion360].[tblCatEstatus] CHECK CONSTRAINT [Fk_Evaluacion360TblCatEstatus_Evaluacion360TblCatTiposEstatus_IDTipoEstatus]
GO
ALTER TABLE [Evaluacion360].[tblCatEstatus]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360TblCatEstatus_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatEstatus] CHECK CONSTRAINT [Chk_Evaluacion360TblCatEstatus_Traduccion]
GO
