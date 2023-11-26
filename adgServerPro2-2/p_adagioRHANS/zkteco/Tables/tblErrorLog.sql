USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblErrorLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ErrCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ErrMsg] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DataOrigin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CmdId] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Additional] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DeviceID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [ErrorLog_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
