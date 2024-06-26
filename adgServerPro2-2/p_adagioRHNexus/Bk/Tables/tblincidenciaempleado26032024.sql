USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblincidenciaempleado26032024](
	[IDIncapacidadEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Numero] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Fecha] [date] NOT NULL,
	[Duracion] [int] NOT NULL,
	[IDTipoIncapacidad] [int] NOT NULL,
	[IDClasificacionIncapacidad] [int] NULL,
	[PagoSubsidioEmpresa] [bit] NULL,
	[IDCausaAccidente] [int] NULL,
	[IDCorreccionAccidente] [int] NULL,
	[IDTipoLesion] [int] NULL,
	[Hora] [time](7) NULL,
	[Dia] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoRiesgoIncapacidad] [int] NULL,
	[Permanente] [bit] NULL
) ON [PRIMARY]
GO
