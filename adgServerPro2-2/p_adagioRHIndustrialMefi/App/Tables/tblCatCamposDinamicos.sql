USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatCamposDinamicos](
	[IDCampoDinamico] [int] IDENTITY(1,1) NOT NULL,
	[Tabla] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Campo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCampo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AliasCampo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[GrupoCampo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
