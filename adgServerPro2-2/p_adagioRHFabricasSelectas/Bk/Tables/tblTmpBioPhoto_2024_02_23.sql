USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTmpBioPhoto_2024_02_23](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FileName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Type] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Size] [int] NULL,
	[Content] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
