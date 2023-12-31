USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPrestamosDetalles20210429](
	[IDPrestamoDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDPrestamo] [int] NOT NULL,
	[IDPeriodo] [int] NULL,
	[MontoCuota] [decimal](18, 2) NULL,
	[FechaPago] [date] NOT NULL,
	[Receptor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NULL
) ON [PRIMARY]
GO
