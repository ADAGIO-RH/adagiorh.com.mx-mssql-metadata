USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatEstatusObjetivos](
	[IDEstatusObjetivo] [int] NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Orden] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatEstatusObjetivos_IDEstatusObjetivo] PRIMARY KEY CLUSTERED 
(
	[IDEstatusObjetivo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatEstatusObjetivos] ADD  CONSTRAINT [D_Evaluacion360TblCatEstatusObjetivos_Orden]  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [Evaluacion360].[tblCatEstatusObjetivos]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360TblCatEstatusObjetivos_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatEstatusObjetivos] CHECK CONSTRAINT [Chk_Evaluacion360TblCatEstatusObjetivos_Traduccion]
GO
