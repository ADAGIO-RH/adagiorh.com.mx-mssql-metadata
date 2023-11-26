USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatFondosAhorro22nov2023](
	[IDFondoAhorro] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoNomina] [int] NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[IDPeriodoInicial] [int] NOT NULL,
	[IDPeriodoFinal] [int] NULL,
	[IDPeriodoPago] [int] NULL,
	[FechaHora] [datetime] NULL,
	[IDUsuario] [int] NOT NULL
) ON [PRIMARY]
GO
