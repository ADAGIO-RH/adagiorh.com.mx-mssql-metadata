USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblDevice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DevName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ATTLOGStamp] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OPERLOGStamp] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ATTPHOTOStamp] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ErrorDelay] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Delay] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TransFlag] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Realtime] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TransInterval] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TransTimes] [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Encrypt] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[LastRequestTime] [datetime] NULL,
	[DevIP] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DevMac] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DevFPVersion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DevFirmwareVersion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UserCount] [int] NULL,
	[AttCount] [int] NULL,
	[FpCount] [int] NULL,
	[TimeZone] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Timeout] [int] NULL,
	[SyncTime] [int] NULL,
	[VendorName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IRTempDetectionFunOn] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MaskDetectionFunOn] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UserPicURLFunOn] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MultiBioDataSupport] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MultiBioPhotoSupport] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MultiBioVersion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MultiBioCount] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MaxMultiBioDataCount] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MaxMultiBioPhotoCount] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[LastSync] [datetime] NULL,
	[LastFullDownload] [datetime] NULL,
	[ERRORLOGStamp] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Device_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [zkteco].[tblDevice] ADD  DEFAULT ('0') FOR [UserPicURLFunOn]
GO
