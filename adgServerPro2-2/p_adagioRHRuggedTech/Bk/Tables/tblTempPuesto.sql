USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTempPuesto](
	[PositionTitle_english] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PositionTitle_spanish] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[JobBand] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PayGrade] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IncentiveTarget] [decimal](18, 4) NULL,
	[Minimum] [decimal](18, 4) NULL,
	[MidPoint] [decimal](18, 4) NULL,
	[Maximum] [decimal](18, 4) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
