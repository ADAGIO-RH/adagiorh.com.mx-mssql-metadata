USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatTiposEstatus](
	[IDTipoEstatus] [int] NOT NULL,
	[TipoEstatus] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatTiposEstatus_IDTipoEstatus] PRIMARY KEY CLUSTERED 
(
	[IDTipoEstatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatTiposEstatus]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360TblCatTiposEstatus_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatTiposEstatus] CHECK CONSTRAINT [Chk_Evaluacion360TblCatTiposEstatus_Traduccion]
GO
