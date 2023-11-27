USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblConfigDashboardNomina_OCT_2023](
	[IDConfigDashboardNomina] [int] NOT NULL,
	[BotonLabel] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Filtro] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDPais] [int] NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
