USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblLayoutPagoParametros20210215](
	[IDLayoutPagoParametros] [int] IDENTITY(1,1) NOT NULL,
	[IDLayoutPago] [int] NOT NULL,
	[IDTipoLayoutParametro] [int] NOT NULL,
	[Valor] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
