USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblOpLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Operator] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OpTime] [datetime] NULL,
	[OpType] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[User] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Obj1] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Obj2] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Obj3] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Obj4] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DeviceID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [OpLog_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
