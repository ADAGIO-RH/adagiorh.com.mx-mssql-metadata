USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblDatosExtraClientes20240223](
	[IDDatoExtraCliente] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDCatDatoExtraCliente] [int] NOT NULL,
	[Valor] [App].[LGDescription] NULL
) ON [PRIMARY]
GO
