USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[TblDimensionesDeDominio](
	[IDDimensionDominio] [int] IDENTITY(1,1) NOT NULL,
	[IDEncuestaEmpleado] [int] NOT NULL,
	[Dominio] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDDominio] [int] NULL,
	[IDDimension] [int] NULL
) ON [PRIMARY]
GO
