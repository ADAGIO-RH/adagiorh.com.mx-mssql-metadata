USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblUserInfo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PIN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UserName] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Passwd] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCard] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Grp] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TZ] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Pri] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [UserInfo_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
