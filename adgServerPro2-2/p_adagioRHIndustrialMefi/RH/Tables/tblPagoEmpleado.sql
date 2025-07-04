USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblPagoEmpleado](
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
	[IDBanco] [int] NULL,
 CONSTRAINT [PK_RHTblPagoEmpleado_IDPagoEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDPagoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [u_LayoutConceptoImporteEmpleado] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[IDLayoutPago] ASC,
	[IDConcepto] ASC,
	[ImporteTotal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblPagoEmpleado_IDConcepto] ON [RH].[tblPagoEmpleado]
(
	[IDConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblPagoEmpleado_IDEmpleado] ON [RH].[tblPagoEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblPagoEmpleado_IDLayoutPago] ON [RH].[tblPagoEmpleado]
(
	[IDLayoutPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblPagoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_NominatblCatConceptos_RHtblPagoEmpleado_IDConceptos] FOREIGN KEY([IDConcepto])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [RH].[tblPagoEmpleado] CHECK CONSTRAINT [FK_NominatblCatConceptos_RHtblPagoEmpleado_IDConceptos]
GO
ALTER TABLE [RH].[tblPagoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_NominatblLayoutPago_RHtblPagoEmpleado_IDTipoLayout] FOREIGN KEY([IDLayoutPago])
REFERENCES [Nomina].[tblLayoutPago] ([IDLayoutPago])
GO
ALTER TABLE [RH].[tblPagoEmpleado] CHECK CONSTRAINT [FK_NominatblLayoutPago_RHtblPagoEmpleado_IDTipoLayout]
GO
ALTER TABLE [RH].[tblPagoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_RHtblPagoEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblPagoEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_RHtblPagoEmpleado_IDEmpleado]
GO
ALTER TABLE [RH].[tblPagoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatBancos_RHtblPagoEmpleado_IDBanco] FOREIGN KEY([IDBanco])
REFERENCES [Sat].[tblCatBancos] ([IDBanco])
GO
ALTER TABLE [RH].[tblPagoEmpleado] CHECK CONSTRAINT [FK_SatTblCatBancos_RHtblPagoEmpleado_IDBanco]
GO
