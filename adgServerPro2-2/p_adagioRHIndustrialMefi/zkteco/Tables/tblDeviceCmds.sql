USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblDeviceCmds](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Content] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CommitTime] [datetime] NULL,
	[TransTime] [datetime] NULL,
	[ResponseTime] [datetime] NULL,
	[ReturnValue] [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Executed] [bit] NULL,
 CONSTRAINT [DeviceCmds_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [zkteco].[tblDeviceCmds] ADD  CONSTRAINT [D_zktecoTblDeviceCmds_Executed]  DEFAULT ((0)) FOR [Executed]
GO
