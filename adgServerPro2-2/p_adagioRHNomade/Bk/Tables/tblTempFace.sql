USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTempFace](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Pin] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fid] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Size] [int] NULL,
	[Valid] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Tmp] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Ver] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
