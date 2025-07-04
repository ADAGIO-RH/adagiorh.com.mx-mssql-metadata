USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCatTipoNomina](
	[IDTipoNomina] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDPeriodicidadPago] [int] NOT NULL,
	[IDPeriodo] [int] NULL,
	[IDCliente] [int] NULL,
	[IDPais] [int] NULL,
	[Asimilados] [bit] NULL,
	[ConfigISRProporcional] [bit] NULL,
	[IDISRProporcional] [int] NULL,
	[IDISRProporcionalFiniquito] [int] NULL,
 CONSTRAINT [PK_NominaTblCatTipoNomina_IDTipoNomina] PRIMARY KEY CLUSTERED 
(
	[IDTipoNomina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatTipoNomina_IDCliente] ON [Nomina].[tblCatTipoNomina]
(
	[IDCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatTipoNomina_IDPeriodicidadPago] ON [Nomina].[tblCatTipoNomina]
(
	[IDPeriodicidadPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatTipoNomina_IDPeriodo] ON [Nomina].[tblCatTipoNomina]
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblCatTipoNomina] ADD  CONSTRAINT [d_NominaTblCatTipoNomina_Asimilados]  DEFAULT ((0)) FOR [Asimilados]
GO
ALTER TABLE [Nomina].[tblCatTipoNomina]  WITH CHECK ADD  CONSTRAINT [FK_IDISRProporcional_tblCatTipoNomina_tblCatTipoISRProporcional] FOREIGN KEY([IDISRProporcional])
REFERENCES [Nomina].[tblCatTipoISRProporcional] ([IDISRProporcional])
GO
ALTER TABLE [Nomina].[tblCatTipoNomina] CHECK CONSTRAINT [FK_IDISRProporcional_tblCatTipoNomina_tblCatTipoISRProporcional]
GO
ALTER TABLE [Nomina].[tblCatTipoNomina]  WITH CHECK ADD  CONSTRAINT [FK_IDISRProporcionalFiniquito_tblCatTipoNomina_tblCatTipoISRProporcional] FOREIGN KEY([IDISRProporcionalFiniquito])
REFERENCES [Nomina].[tblCatTipoISRProporcional] ([IDISRProporcional])
GO
ALTER TABLE [Nomina].[tblCatTipoNomina] CHECK CONSTRAINT [FK_IDISRProporcionalFiniquito_tblCatTipoNomina_tblCatTipoISRProporcional]
GO
ALTER TABLE [Nomina].[tblCatTipoNomina]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblCatTipoNomina_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblCatTipoNomina] CHECK CONSTRAINT [Fk_NominaTblCatTipoNomina_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblCatTipoNomina]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatClientes_NominaTblCatTipoNomina_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [Nomina].[tblCatTipoNomina] CHECK CONSTRAINT [FK_RHtblCatClientes_NominaTblCatTipoNomina_IDCliente]
GO
ALTER TABLE [Nomina].[tblCatTipoNomina]  WITH CHECK ADD  CONSTRAINT [FK_SATTblCatPaises_NominaTblCatTipoNomina_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Nomina].[tblCatTipoNomina] CHECK CONSTRAINT [FK_SATTblCatPaises_NominaTblCatTipoNomina_IDPais]
GO
ALTER TABLE [Nomina].[tblCatTipoNomina]  WITH CHECK ADD  CONSTRAINT [FK_SATtblCatPeriodicidadesPago_NominatblCatTipoNomina_IDPeriodicidadPago] FOREIGN KEY([IDPeriodicidadPago])
REFERENCES [Sat].[tblCatPeriodicidadesPago] ([IDPeriodicidadPago])
GO
ALTER TABLE [Nomina].[tblCatTipoNomina] CHECK CONSTRAINT [FK_SATtblCatPeriodicidadesPago_NominatblCatTipoNomina_IDPeriodicidadPago]
GO
