USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblDetallePeriodoPresupuesto](
	[IDDetallePeriodoPresupuesto] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDPeriodo] [int] NOT NULL,
	[IDConcepto] [int] NOT NULL,
	[CantidadMonto] [decimal](18, 2) NULL,
	[CantidadDias] [decimal](18, 2) NULL,
	[CantidadVeces] [decimal](18, 2) NULL,
	[CantidadOtro1] [decimal](18, 2) NULL,
	[CantidadOtro2] [decimal](18, 2) NULL,
	[ImporteGravado] [decimal](18, 2) NULL,
	[ImporteExcento] [decimal](18, 2) NULL,
	[ImporteOtro] [decimal](18, 2) NULL,
	[ImporteTotal1] [decimal](18, 2) NULL,
	[ImporteTotal2] [decimal](18, 2) NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDReferencia] [int] NULL,
	[ImporteAcumuladoTotales]  AS ([ImporteTotal1]+[ImporteTotal2]),
 CONSTRAINT [PK_NominatblDetallePeriodoPresupuesto_IDDetallePeriodo] PRIMARY KEY CLUSTERED 
(
	[IDDetallePeriodoPresupuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] SET (LOCK_ESCALATION = DISABLE)
GO
CREATE NONCLUSTERED INDEX [idx_NominaTblDetallePeriodoPresupuesto_IDConcepto] ON [Nomina].[tblDetallePeriodoPresupuesto]
(
	[IDConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominaTblDetallePeriodoPresupuesto_IDEmpleado] ON [Nomina].[tblDetallePeriodoPresupuesto]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblDetallePeriodoPresupuesto_IDEmpleado_IDPeriodo_IDConcepto] ON [Nomina].[tblDetallePeriodoPresupuesto]
(
	[IDEmpleado] ASC,
	[IDPeriodo] ASC,
	[IDConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominaTblDetallePeriodoPresupuesto_IDPeriodo] ON [Nomina].[tblDetallePeriodoPresupuesto]
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblDetallePeriodoPresupuesto_IDReferencia_IDPeriodoIDConceptoImporteTotal1] ON [Nomina].[tblDetallePeriodoPresupuesto]
(
	[IDReferencia] ASC
)
INCLUDE([IDPeriodo],[IDConcepto],[ImporteTotal1]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_NONCLUSTERED_NominatblCatTipoConcepto_Descripcion] ON [Nomina].[tblDetallePeriodoPresupuesto]
(
	[Descripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NONCLUSTERED_NominaTblDetallePeriodoPresupuesto_IDEmpledo_IDPeriodo] ON [Nomina].[tblDetallePeriodoPresupuesto]
(
	[IDEmpleado] ASC,
	[IDPeriodo] ASC
)
INCLUDE([IDDetallePeriodoPresupuesto],[IDConcepto],[CantidadMonto],[CantidadDias],[CantidadVeces],[CantidadOtro1],[CantidadOtro2],[ImporteGravado],[ImporteExcento],[ImporteOtro],[ImporteTotal1],[ImporteTotal2],[Descripcion],[IDReferencia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_NominaTblDetallePeriodoPresupuesto_IDEmpleadoIDPeriodoIDConceptoDescripcionIDReferencia] ON [Nomina].[tblDetallePeriodoPresupuesto]
(
	[IDEmpleado] ASC,
	[IDPeriodo] ASC,
	[IDConcepto] ASC,
	[Descripcion] ASC,
	[IDReferencia] ASC
)
WHERE ([Descripcion] IS NOT NULL AND [IDReferencia] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoPresupuesto_CantidadDias]  DEFAULT ((0)) FOR [CantidadDias]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoPresupuesto_CantidadVeces]  DEFAULT ((0)) FOR [CantidadVeces]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoPresupuesto_CantidadOtro1]  DEFAULT ((0)) FOR [CantidadOtro1]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoPresupuesto_CantidadOtro2]  DEFAULT ((0)) FOR [CantidadOtro2]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoPresupuesto_ImporteGravado]  DEFAULT ((0)) FOR [ImporteGravado]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoPresupuesto_ImporteExcento]  DEFAULT ((0)) FOR [ImporteExcento]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoPresupuesto_ImporteOtro]  DEFAULT ((0)) FOR [ImporteOtro]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoPresupuesto_ImporteTotal1]  DEFAULT ((0)) FOR [ImporteTotal1]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoPresupuesto_ImporteTotal2]  DEFAULT ((0)) FOR [ImporteTotal2]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatConceptos_NominaDetallePeriodoPresupuesto_IDConcepto] FOREIGN KEY([IDConcepto])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] CHECK CONSTRAINT [FK_NominaTblCatConceptos_NominaDetallePeriodoPresupuesto_IDConcepto]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatPeriodos_NominaDetallePeriodoPresupuesto_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] CHECK CONSTRAINT [FK_NominaTblCatPeriodos_NominaDetallePeriodoPresupuesto_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_NominatblDetallePeriodoPresupuesto_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblDetallePeriodoPresupuesto] CHECK CONSTRAINT [FK_RHtblEmpleados_NominatblDetallePeriodoPresupuesto_IDEmpleado]
GO
