USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[tblCatCategories](
	[IDCategory] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDSource] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Category] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_log_tblCatCategories_IDCategory] PRIMARY KEY CLUSTERED 
(
	[IDCategory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [log].[tblCatCategories]  WITH CHECK ADD  CONSTRAINT [FK_logtblCatCategories_logtblCatCategories_IDSource] FOREIGN KEY([IDSource])
REFERENCES [log].[tblCatSources] ([IDSource])
GO
ALTER TABLE [log].[tblCatCategories] CHECK CONSTRAINT [FK_logtblCatCategories_logtblCatCategories_IDSource]
GO
