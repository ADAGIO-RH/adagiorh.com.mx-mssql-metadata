USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPrestamos12032025](
	[IDPrestamo] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoPrestamo] [int] NOT NULL,
	[IDEstatusPrestamo] [int] NULL,
	[MontoPrestamo] [decimal](18, 2) NULL,
	[Cuotas] [decimal](18, 2) NULL,
	[CantidadCuotas] [int] NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaCreacion] [date] NOT NULL,
	[FechaInicioPago] [date] NOT NULL,
	[Intereses] [decimal](18, 2) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
