USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblcatregpatronal20240312](
	[IDRegPatronal] [int] IDENTITY(1,1) NOT NULL,
	[RegistroPatronal] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RazonSocial] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ActividadEconomica] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCodigoPostal] [int] NULL,
	[IDEstado] [int] NULL,
	[IDMunicipio] [int] NULL,
	[IDColonia] [int] NULL,
	[IDPais] [int] NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Telefono] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConvenioSubsidios] [bit] NULL,
	[DelegacionIMSS] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SubDelegacionIMSS] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaAfiliacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RepresentanteLegal] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OcupacionRepLegal] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDClaseRiesgo] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
