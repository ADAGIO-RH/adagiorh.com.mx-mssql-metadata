USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SAP].[tblCatPuestosEng](
	[IDPuestoEng] [int] IDENTITY(1,1) NOT NULL,
	[IDPuesto] [int] NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[JobCode] [int] NULL,
	[PositionCode] [int] NULL,
	[Band] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
