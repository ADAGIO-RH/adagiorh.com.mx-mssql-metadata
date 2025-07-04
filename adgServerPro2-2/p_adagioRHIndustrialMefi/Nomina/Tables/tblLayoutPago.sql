USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblLayoutPago](
	[IDLayoutPago] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoLayout] [int] NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDConcepto] [int] NOT NULL,
	[ImporteTotal] [int] NOT NULL,
	[IDConceptoFiniquito] [int] NULL,
	[ImporteTotalFiniquito] [int] NULL,
 CONSTRAINT [PK_NominaTblLayoutPago_IDLayoutPago] PRIMARY KEY CLUSTERED 
(
	[IDLayoutPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblLayoutPago_IDConcepto] ON [Nomina].[tblLayoutPago]
(
	[IDConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblLayoutPago_IDConceptoFiniquito] ON [Nomina].[tblLayoutPago]
(
	[IDConceptoFiniquito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblLayoutPago_IDTipoLayout] ON [Nomina].[tblLayoutPago]
(
	[IDTipoLayout] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblLayoutPago] ADD  DEFAULT ((1)) FOR [ImporteTotal]
GO
ALTER TABLE [Nomina].[tblLayoutPago]  WITH CHECK ADD  CONSTRAINT [FK_NominatblCatConceptos_NominaTblLayoutPago_IDConcepto] FOREIGN KEY([IDConcepto])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [Nomina].[tblLayoutPago] CHECK CONSTRAINT [FK_NominatblCatConceptos_NominaTblLayoutPago_IDConcepto]
GO
ALTER TABLE [Nomina].[tblLayoutPago]  WITH CHECK ADD  CONSTRAINT [FK_NominatblCatNomina_NominaTblLayoutPago_IDConceptoFiniquito] FOREIGN KEY([IDConceptoFiniquito])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [Nomina].[tblLayoutPago] CHECK CONSTRAINT [FK_NominatblCatNomina_NominaTblLayoutPago_IDConceptoFiniquito]
GO
ALTER TABLE [Nomina].[tblLayoutPago]  WITH CHECK ADD  CONSTRAINT [FK_NominatblCatTipoLayout_NominaTblLayoutPago_IDTipoLayout] FOREIGN KEY([IDTipoLayout])
REFERENCES [Nomina].[tblCatTiposLayout] ([IDTipoLayout])
GO
ALTER TABLE [Nomina].[tblLayoutPago] CHECK CONSTRAINT [FK_NominatblCatTipoLayout_NominaTblLayoutPago_IDTipoLayout]
GO
