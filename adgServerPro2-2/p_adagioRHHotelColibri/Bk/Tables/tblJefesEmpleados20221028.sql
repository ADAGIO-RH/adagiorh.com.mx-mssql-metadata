USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblJefesEmpleados20221028](
	[IDJefeEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDJefe] [int] NOT NULL,
	[FechaReg] [datetime] NULL
) ON [PRIMARY]
GO
