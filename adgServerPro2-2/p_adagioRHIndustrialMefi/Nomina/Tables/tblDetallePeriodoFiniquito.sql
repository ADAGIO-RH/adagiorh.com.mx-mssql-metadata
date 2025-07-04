USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblDetallePeriodoFiniquito](
	[IDDetallePeriodo] [int] IDENTITY(1,1) NOT NULL,
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
 CONSTRAINT [PK_NominatblDetallePeriodoFiniquito_IDDetallePeriodo] PRIMARY KEY CLUSTERED 
(
	[IDDetallePeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] SET (LOCK_ESCALATION = DISABLE)
GO
CREATE NONCLUSTERED INDEX [idx_NominatblDetallePeriodoFiniquito_IDConcepto] ON [Nomina].[tblDetallePeriodoFiniquito]
(
	[IDConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblDetallePeriodoFiniquito_IDEmpleado] ON [Nomina].[tblDetallePeriodoFiniquito]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblDetallePeriodoFiniquito_IDPeriodo] ON [Nomina].[tblDetallePeriodoFiniquito]
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoFiniquito_CantidadDias]  DEFAULT ((0)) FOR [CantidadDias]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoFiniquito_CantidadVeces]  DEFAULT ((0)) FOR [CantidadVeces]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoFiniquito_CantidadOtro1]  DEFAULT ((0)) FOR [CantidadOtro1]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoFiniquito_CantidadOtro2]  DEFAULT ((0)) FOR [CantidadOtro2]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoFiniquito_ImporteGravado]  DEFAULT ((0)) FOR [ImporteGravado]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoFiniquito_ImporteExcento]  DEFAULT ((0)) FOR [ImporteExcento]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoFiniquito_ImporteOtro]  DEFAULT ((0)) FOR [ImporteOtro]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoFiniquito_ImporteTotal1]  DEFAULT ((0)) FOR [ImporteTotal1]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] ADD  CONSTRAINT [DF_NominaTblDetallePeriodoFiniquito_ImporteTotal2]  DEFAULT ((0)) FOR [ImporteTotal2]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatConceptos_NominatblDetallePeriodoFiniquito_IDConcepto] FOREIGN KEY([IDConcepto])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] CHECK CONSTRAINT [FK_NominaTblCatConceptos_NominatblDetallePeriodoFiniquito_IDConcepto]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatPeriodos_NominatblDetallePeriodoFiniquito_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] CHECK CONSTRAINT [FK_NominaTblCatPeriodos_NominatblDetallePeriodoFiniquito_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_NominatblDetallePeriodoFiniquito_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblDetallePeriodoFiniquito] CHECK CONSTRAINT [FK_RHtblEmpleados_NominatblDetallePeriodoFiniquito_IDEmpleado]
GO
