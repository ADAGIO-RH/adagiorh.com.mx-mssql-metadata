USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblAsistenciasNormalizadas](
	[FechaNormalizacion] [date] NULL,
	[Tipo] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Total] [int] NULL,
	[Autorizado] [int] NULL,
	[IDCliente] [int] NULL,
	[IDRazonSocial] [int] NULL,
	[IDRegPatronal] [int] NULL,
	[IDCentroCosto] [int] NULL,
	[IDDepartamento] [int] NULL,
	[IDArea] [int] NULL,
	[IDPuesto] [int] NULL,
	[IDTipoPrestacion] [int] NULL,
	[IDSucursal] [int] NULL,
	[IDDivision] [int] NULL,
	[IDRegion] [int] NULL,
	[IDClasificacionCorporativa] [int] NULL
) ON [PRIMARY]
GO
