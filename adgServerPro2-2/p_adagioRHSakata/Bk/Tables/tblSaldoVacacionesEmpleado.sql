USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblSaldoVacacionesEmpleado](
	[IDSaldoVacacionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Anio] [int] NOT NULL,
	[IDMovAfiliatorio] [int] NOT NULL,
	[IDTipoPrestacion] [int] NOT NULL,
	[DiasVigencia] [int] NULL,
	[FechaGeneracion] [datetime] NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[FechaInicioDisponible] [date] NOT NULL,
	[FechaFinDisponible] [date] NOT NULL,
	[IDAjusteSaldo] [int] NULL,
	[IDIncidenciaEmpleado] [int] NULL,
	[IDFiniquito] [int] NULL
) ON [PRIMARY]
GO
