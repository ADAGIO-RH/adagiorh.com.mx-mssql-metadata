USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblempresa20230609](
	[IdEmpresa] [int] IDENTITY(1,1) NOT NULL,
	[NombreComercial] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RFC] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCodigoPostal] [int] NULL,
	[IDEstado] [int] NULL,
	[IDMunicipio] [int] NULL,
	[IDColonia] [int] NULL,
	[IDPais] [int] NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegFonacot] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegInfonavit] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegSIEM] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegEstatal] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRegimenFiscal] [int] NULL,
	[IDOrigenRecurso] [int] NULL,
	[PasswordInfonavit] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURP] [varchar](18) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
