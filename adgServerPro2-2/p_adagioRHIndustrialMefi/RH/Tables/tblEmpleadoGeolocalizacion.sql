USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblEmpleadoGeolocalizacion](
	[IDEmpleadoGeolocalizacion] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[OmitirGeolocalizacion] [bit] NULL
) ON [PRIMARY]
GO
