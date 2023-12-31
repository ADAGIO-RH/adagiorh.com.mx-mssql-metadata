USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblContratoEmpleado20220808](
	[IDContratoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoContrato] [int] NULL,
	[IDDocumento] [int] NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[Duracion] [int] NULL,
	[IDTipoDocumento] [int] NULL,
	[FechaGeneracion] [datetime] NULL,
	[IDTipoTrabajador] [int] NULL
) ON [PRIMARY]
GO
