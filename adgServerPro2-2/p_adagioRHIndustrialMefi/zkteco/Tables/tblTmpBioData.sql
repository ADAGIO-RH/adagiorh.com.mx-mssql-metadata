USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblTmpBioData](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[No] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Index] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Valid] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Duress] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Type] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MajorVer] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MinorVer] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Format] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Tmp] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [TmpBioData_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [zkteco].[tblTmpBioData] ADD  DEFAULT ('0') FOR [No]
GO
ALTER TABLE [zkteco].[tblTmpBioData] ADD  DEFAULT ('1') FOR [Valid]
GO
ALTER TABLE [zkteco].[tblTmpBioData] ADD  DEFAULT ('0') FOR [Duress]
GO
