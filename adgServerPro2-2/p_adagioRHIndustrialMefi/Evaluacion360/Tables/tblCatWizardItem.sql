USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatWizardItem](
	[IDWizardItem] [int] NOT NULL,
	[Item] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Url] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NOT NULL,
	[JSONData] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatWizardItem_IDWizardItem] PRIMARY KEY CLUSTERED 
(
	[IDWizardItem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatWizardItem]  WITH CHECK ADD  CONSTRAINT [chk_Evaluacion360TblCatWizardItem_JSONData] CHECK  ((isjson([JSONData])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatWizardItem] CHECK CONSTRAINT [chk_Evaluacion360TblCatWizardItem_JSONData]
GO
