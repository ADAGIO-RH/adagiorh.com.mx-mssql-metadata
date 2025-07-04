USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tempUrlsTraduccion](
	[IDUrl] [int] NOT NULL,
	[IDModulo] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[URL] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Tipo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoPermiso] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDController] [int] NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
