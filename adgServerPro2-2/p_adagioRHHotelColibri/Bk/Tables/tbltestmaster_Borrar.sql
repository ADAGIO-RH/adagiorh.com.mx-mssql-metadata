USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tbltestmaster_Borrar](
	[IDEmpleado] [int] NOT NULL,
	[FechaAlta] [date] NULL,
	[FechaBaja] [date] NULL,
	[FechaReingreso] [date] NULL,
	[FechaReingresoAntiguedad] [date] NULL,
	[IDMovAfiliatorio] [int] NULL
) ON [PRIMARY]
GO
