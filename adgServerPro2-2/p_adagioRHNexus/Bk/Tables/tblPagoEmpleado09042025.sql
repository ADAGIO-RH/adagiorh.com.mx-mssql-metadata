USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPagoEmpleado09042025](
	[IDPagoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDLayoutPago] [int] NULL,
	[IDConcepto] [int] NULL,
	[ImporteTotal] [int] NULL,
	[Cuenta] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sucursal] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interbancaria] [varchar](18) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Tarjeta] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDBancario] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDBanco] [int] NULL
) ON [PRIMARY]
GO
