USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatTipoNomina20201117](
	[IDTipoNomina] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDPeriodicidadPago] [int] NOT NULL,
	[IDPeriodo] [int] NULL,
	[IDCliente] [int] NULL
) ON [PRIMARY]
GO
