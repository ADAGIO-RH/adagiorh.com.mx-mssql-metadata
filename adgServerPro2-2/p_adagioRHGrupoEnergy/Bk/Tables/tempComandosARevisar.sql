USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tempComandosARevisar](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Content] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CommitTime] [datetime] NULL,
	[TransTime] [datetime] NULL,
	[ResponseTime] [datetime] NULL,
	[ReturnValue] [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Executed] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
