USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblcatbancosoct2023](
	[IDBanco] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RazonSocial] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClaveTransferSantander] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClaveTransferKUSPIT] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
