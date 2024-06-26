USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTempDeviceCmds20240503cc7073](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Template] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CreatedAt] [datetime] NULL,
	[ExecutedAt] [datetime] NULL,
	[Executed] [bit] NULL,
	[Content] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[BioDataTemplate] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
