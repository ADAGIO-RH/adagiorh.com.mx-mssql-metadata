USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblMessages](
	[IDMessage] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Level] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Message] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDIdioma] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_AppTblMessages_IDMessage_IDIdioma] PRIMARY KEY CLUSTERED 
(
	[IDMessage] ASC,
	[IDIdioma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblMessages]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblMessages_AppTblLevels_Level] FOREIGN KEY([Level])
REFERENCES [App].[tblLevels] ([Level])
GO
ALTER TABLE [App].[tblMessages] CHECK CONSTRAINT [Fk_AppTblMessages_AppTblLevels_Level]
GO
