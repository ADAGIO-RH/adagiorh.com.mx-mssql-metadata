USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatDiasFestivos20230125](
	[IDDiaFestivo] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[FechaReal] [date] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Autorizado] [bit] NULL,
	[IDPais] [int] NULL
) ON [PRIMARY]
GO
