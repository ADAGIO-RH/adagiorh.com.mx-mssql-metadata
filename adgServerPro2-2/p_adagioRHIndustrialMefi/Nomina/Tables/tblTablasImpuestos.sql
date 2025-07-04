USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblTablasImpuestos](
	[IDTablaImpuesto] [int] IDENTITY(1,1) NOT NULL,
	[IDPeriodicidadPago] [int] NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[IDCalculo] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPais] [int] NULL,
 CONSTRAINT [Pk_NominaTblTablasImpuestos_IDTablaImpuesto] PRIMARY KEY CLUSTERED 
(
	[IDTablaImpuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblTablasImpuestos_IDPeriodicidadPagoEjercicioIDCalculoIDPais] UNIQUE NONCLUSTERED 
(
	[IDPeriodicidadPago] ASC,
	[Ejercicio] ASC,
	[IDCalculo] ASC,
	[IDPais] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblTablasImpuestos_Ejercicio] ON [Nomina].[tblTablasImpuestos]
(
	[Ejercicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblTablasImpuestos_IDCalculo] ON [Nomina].[tblTablasImpuestos]
(
	[IDCalculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblTablasImpuestos_IDPeriodicidadPago] ON [Nomina].[tblTablasImpuestos]
(
	[IDPeriodicidadPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblTablasImpuestos]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTablasImpuestos_IDCalculo] FOREIGN KEY([IDCalculo])
REFERENCES [Nomina].[tblCatTipoCalculoISR] ([IDCalculo])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblTablasImpuestos] CHECK CONSTRAINT [Fk_NominaTablasImpuestos_IDCalculo]
GO
ALTER TABLE [Nomina].[tblTablasImpuestos]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblTablasImpuestos_IDPeriodicidadPago] FOREIGN KEY([IDPeriodicidadPago])
REFERENCES [Sat].[tblCatPeriodicidadesPago] ([IDPeriodicidadPago])
GO
ALTER TABLE [Nomina].[tblTablasImpuestos] CHECK CONSTRAINT [Fk_NominaTblTablasImpuestos_IDPeriodicidadPago]
GO
ALTER TABLE [Nomina].[tblTablasImpuestos]  WITH CHECK ADD  CONSTRAINT [FK_SATTblCatPaises_NominaTblTablasImpuestos_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Nomina].[tblTablasImpuestos] CHECK CONSTRAINT [FK_SATTblCatPaises_NominaTblTablasImpuestos_IDPais]
GO
