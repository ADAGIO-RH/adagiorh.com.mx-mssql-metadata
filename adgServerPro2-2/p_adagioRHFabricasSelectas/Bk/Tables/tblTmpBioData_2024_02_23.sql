USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTmpBioData_2024_02_23](
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
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
