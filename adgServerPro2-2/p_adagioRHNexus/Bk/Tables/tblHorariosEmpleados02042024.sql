USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblHorariosEmpleados02042024](
	[IDHorarioEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDHorario] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[FechaHoraRegistro] [datetime] NULL
) ON [PRIMARY]
GO
