USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblHorariosEmpleados2025_04_04](
	[IDHorarioEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDHorario] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[FechaHoraRegistro] [datetime] NULL
) ON [PRIMARY]
GO
