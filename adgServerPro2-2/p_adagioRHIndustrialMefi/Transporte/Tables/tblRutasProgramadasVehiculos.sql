USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblRutasProgramadasVehiculos](
	[IDRutaProgramadaVehiculo] [int] IDENTITY(1,1) NOT NULL,
	[IDRutaProgramada] [int] NULL,
	[IDVehiculo] [int] NULL,
	[CostoUnidad] [decimal](18, 0) NULL,
	[IDTipoCosto] [int] NULL,
	[Capacidad] [int] NULL
) ON [PRIMARY]
GO
