USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[TBLColonias](
	[Codigo] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCodigoPostal] [int] NULL,
	[CodigoPostal] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreAsentamiento] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
