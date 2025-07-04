USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblIconosInformacion](
	[IDIconoInformacion] [int] IDENTITY(1,1) NOT NULL,
	[url] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[jQuerySelector] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[title] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[href] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_AppTblIconosInformacion_IDIconoInformacion] PRIMARY KEY CLUSTERED 
(
	[IDIconoInformacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
