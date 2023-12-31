USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatSucursales03082022](
	[IDSucursal] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CuentaContable] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Calle] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDColonia] [int] NULL,
	[IDMunicipio] [int] NULL,
	[IDEstado] [int] NULL,
	[IDPais] [int] NULL,
	[Telefono] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Responsable] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Email] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCodigoPostal] [int] NULL,
	[ClaveEstablecimiento] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstadoSTPS] [int] NULL,
	[IDMunicipioSTPS] [int] NULL,
	[Latitud] [float] NULL,
	[Longitud] [float] NULL
) ON [PRIMARY]
GO
