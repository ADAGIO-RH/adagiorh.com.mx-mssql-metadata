USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblTablasImpuestosPrevioActualizacion2025](
	[IDTablaImpuesto] [int] IDENTITY(1,1) NOT NULL,
	[IDPeriodicidadPago] [int] NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[IDCalculo] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPais] [int] NULL
) ON [PRIMARY]
GO
