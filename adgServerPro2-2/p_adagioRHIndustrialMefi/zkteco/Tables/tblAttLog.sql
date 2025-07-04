USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblAttLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PIN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AttTime] [datetime] NULL,
	[Status] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Verify] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[WorkCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Reserved1] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Reserved2] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DeviceID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MaskFlag] [int] NULL,
	[Temperature] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [AttLog_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
