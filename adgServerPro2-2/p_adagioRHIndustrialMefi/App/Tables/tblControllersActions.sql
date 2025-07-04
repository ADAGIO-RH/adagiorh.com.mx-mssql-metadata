USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblControllersActions](
	[Controller] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Action] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ReturnType] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Attributes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Area] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
