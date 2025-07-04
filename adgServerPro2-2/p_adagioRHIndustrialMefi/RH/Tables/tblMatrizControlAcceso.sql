USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblMatrizControlAcceso](
	[IDMatrizControlAcceso] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Color] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[BackgroundColor] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Icono] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Parent] [int] NULL,
	[Orden] [int] NULL,
	[Estatus] [bit] NULL
) ON [PRIMARY]
GO
