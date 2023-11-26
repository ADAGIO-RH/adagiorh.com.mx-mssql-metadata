USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblAreaEmpleadoCarlos](
	[IDAreaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDArea] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL
) ON [PRIMARY]
GO
