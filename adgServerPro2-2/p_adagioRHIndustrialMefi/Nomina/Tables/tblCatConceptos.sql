USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCatConceptos](
	[IDConcepto] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoConcepto] [int] NOT NULL,
	[Estatus] [bit] NOT NULL,
	[Impresion] [bit] NOT NULL,
	[IDCalculo] [int] NOT NULL,
	[CuentaAbono] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CuentaCargo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[bCantidadMonto] [bit] NOT NULL,
	[bCantidadDias] [bit] NOT NULL,
	[bCantidadVeces] [bit] NOT NULL,
	[bCantidadOtro1] [bit] NOT NULL,
	[bCantidadOtro2] [bit] NOT NULL,
	[IDCodigoSAT] [int] NULL,
	[NombreProcedure] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OrdenCalculo] [int] NOT NULL,
	[LFT] [bit] NOT NULL,
	[Personalizada] [bit] NOT NULL,
	[ConDoblePago] [bit] NOT NULL,
	[IDPais] [int] NULL,
	[Presupuesto] [bit] NULL,
 CONSTRAINT [PK_NominaTblCatConceptos_IDConcepto] PRIMARY KEY CLUSTERED 
(
	[IDConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblCatConceptos_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_NominaTblCatConceptos_Codigo] ON [Nomina].[tblCatConceptos]
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominaTblCatConceptos_IDCalculo] ON [Nomina].[tblCatConceptos]
(
	[IDCalculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominaTblCatConceptos_IDTipoConcepto] ON [Nomina].[tblCatConceptos]
(
	[IDTipoConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominaTblCatConceptos_OrdenCalculo] ON [Nomina].[tblCatConceptos]
(
	[OrdenCalculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_NONCLUSTERED_NominatblCatConceptos_Codigo_Descripcion_IDTipoConcepto] ON [Nomina].[tblCatConceptos]
(
	[Codigo] ASC,
	[Descripcion] ASC,
	[IDTipoConcepto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  DEFAULT ((0)) FOR [Impresion]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadMonto]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadDias]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadVeces]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadOtro1]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadOtro2]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  CONSTRAINT [D_NominaTblCatConceptos_LFT]  DEFAULT ((0)) FOR [LFT]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  CONSTRAINT [D_NominaTblCatConceptos_Personalizada]  DEFAULT ((0)) FOR [Personalizada]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  CONSTRAINT [D_NominaTblCatConceptos_ConDoblePago]  DEFAULT ((0)) FOR [ConDoblePago]
GO
ALTER TABLE [Nomina].[tblCatConceptos] ADD  CONSTRAINT [d_NominaTblCatConceptos_Presupuesto]  DEFAULT ((0)) FOR [Presupuesto]
GO
ALTER TABLE [Nomina].[tblCatConceptos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblCatTipoCalculoISR_NominatblCatConceptos_IDCalculo] FOREIGN KEY([IDCalculo])
REFERENCES [Nomina].[tblCatTipoCalculoISR] ([IDCalculo])
GO
ALTER TABLE [Nomina].[tblCatConceptos] CHECK CONSTRAINT [FK_NominatblCatTipoCalculoISR_NominatblCatConceptos_IDCalculo]
GO
ALTER TABLE [Nomina].[tblCatConceptos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblCatTipoConcepto_NominatblCatConceptos_IDTipoConcepto] FOREIGN KEY([IDTipoConcepto])
REFERENCES [Nomina].[tblCatTipoConcepto] ([IDTipoConcepto])
GO
ALTER TABLE [Nomina].[tblCatConceptos] CHECK CONSTRAINT [FK_NominatblCatTipoConcepto_NominatblCatConceptos_IDTipoConcepto]
GO
ALTER TABLE [Nomina].[tblCatConceptos]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_NominaTblCatConceptos_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Nomina].[tblCatConceptos] CHECK CONSTRAINT [FK_SatTblCatPaises_NominaTblCatConceptos_IDPais]
GO
