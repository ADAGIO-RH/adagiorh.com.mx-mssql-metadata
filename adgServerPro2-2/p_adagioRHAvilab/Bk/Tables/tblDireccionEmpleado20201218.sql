USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblDireccionEmpleado20201218](
	[IDDireccionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDPais] [int] NULL,
	[IDEstado] [int] NULL,
	[Estado] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDMunicipio] [int] NULL,
	[Municipio] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDLocalidad] [int] NULL,
	[Localidad] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCodigoPostal] [int] NULL,
	[CodigoPostal] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDColonia] [int] NULL,
	[Colonia] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRuta] [int] NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
