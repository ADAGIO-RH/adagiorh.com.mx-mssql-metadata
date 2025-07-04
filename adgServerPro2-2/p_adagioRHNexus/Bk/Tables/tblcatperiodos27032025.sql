USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblcatperiodos27032025](
	[IDPeriodo] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoNomina] [int] NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[ClavePeriodo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaInicioPago] [date] NOT NULL,
	[FechaFinPago] [date] NOT NULL,
	[FechaInicioIncidencia] [date] NOT NULL,
	[FechaFinIncidencia] [date] NOT NULL,
	[Dias] [int] NULL,
	[AnioInicio] [bit] NOT NULL,
	[AnioFin] [bit] NOT NULL,
	[MesInicio] [bit] NOT NULL,
	[MesFin] [bit] NOT NULL,
	[IDMes] [int] NOT NULL,
	[BimestreInicio] [bit] NOT NULL,
	[BimestreFin] [bit] NOT NULL,
	[Cerrado] [bit] NULL,
	[General] [bit] NULL,
	[Finiquito] [bit] NULL,
	[Especial] [bit] NULL,
	[Aguinaldo] [bit] NULL,
	[PTU] [bit] NULL,
	[DevolucionFondoAhorro] [bit] NULL,
	[Presupuesto] [bit] NULL
) ON [PRIMARY]
GO
