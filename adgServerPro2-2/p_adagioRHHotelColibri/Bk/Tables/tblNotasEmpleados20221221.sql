USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblNotasEmpleados20221221](
	[IDNotaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Nota] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHoraReg] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
