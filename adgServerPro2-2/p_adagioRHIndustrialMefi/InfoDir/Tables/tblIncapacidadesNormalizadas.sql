USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblIncapacidadesNormalizadas](
	[FechaNormalizacion] [date] NULL,
	[IDTipoIncapacidad] [int] NULL,
	[FechaIncapacidad] [date] NULL,
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
