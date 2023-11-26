USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPrestamosFondoAhorro31102023](
	[IDPrestamoFondoAhorro] [int] IDENTITY(1,1) NOT NULL,
	[IDFondoAhorro] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Monto] [decimal](18, 2) NOT NULL,
	[FechaHora] [datetime] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDPrestamo] [int] NOT NULL
) ON [PRIMARY]
GO
