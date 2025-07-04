USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblUrlDependencias](
	[IDUrlDependencia] [int] NOT NULL,
	[IDUrl] [int] NOT NULL,
	[Dependencias] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_APPTblUrlDependencias_IDUrlDependencia] PRIMARY KEY CLUSTERED 
(
	[IDUrlDependencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblUrlDependencias]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatUrl_AppTblUrlDependencias_IDUrl] FOREIGN KEY([IDUrl])
REFERENCES [App].[tblCatUrls] ([IDUrl])
GO
ALTER TABLE [App].[tblUrlDependencias] CHECK CONSTRAINT [FK_AppTblCatUrl_AppTblUrlDependencias_IDUrl]
GO
