USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCatFondosAhorro](
	[IDFondoAhorro] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoNomina] [int] NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[IDPeriodoInicial] [int] NOT NULL,
	[IDPeriodoFinal] [int] NULL,
	[IDPeriodoPago] [int] NULL,
	[FechaHora] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [Pk_NominaTblCatFondosAhorro_IDFondoAhorro] PRIMARY KEY CLUSTERED 
(
	[IDFondoAhorro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatFondosAhorro_Ejercicio] ON [Nomina].[tblCatFondosAhorro]
(
	[Ejercicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatFondosAhorro_IDPeriodoFinal] ON [Nomina].[tblCatFondosAhorro]
(
	[IDPeriodoFinal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatFondosAhorro_IDPeriodoInicial] ON [Nomina].[tblCatFondosAhorro]
(
	[IDPeriodoInicial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatFondosAhorro_IDPeriodoPago] ON [Nomina].[tblCatFondosAhorro]
(
	[IDPeriodoPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatFondosAhorro_IDTipoNomina] ON [Nomina].[tblCatFondosAhorro]
(
	[IDTipoNomina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatFondosAhorro_IDUsuario] ON [Nomina].[tblCatFondosAhorro]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblCatFondosAhorro] ADD  CONSTRAINT [D_NominaTblCatFondosAhorro_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Nomina].[tblCatFondosAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblCatFondosAhorro_NominaTblCatPeriodos_IDPeriodoFinal] FOREIGN KEY([IDPeriodoFinal])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblCatFondosAhorro] CHECK CONSTRAINT [Fk_NominaTblCatFondosAhorro_NominaTblCatPeriodos_IDPeriodoFinal]
GO
ALTER TABLE [Nomina].[tblCatFondosAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblCatFondosAhorro_NominaTblCatPeriodos_IDPeriodoInicial] FOREIGN KEY([IDPeriodoInicial])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblCatFondosAhorro] CHECK CONSTRAINT [Fk_NominaTblCatFondosAhorro_NominaTblCatPeriodos_IDPeriodoInicial]
GO
ALTER TABLE [Nomina].[tblCatFondosAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblCatFondosAhorro_NominaTblCatPeriodos_IDPeriodoPago] FOREIGN KEY([IDPeriodoPago])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblCatFondosAhorro] CHECK CONSTRAINT [Fk_NominaTblCatFondosAhorro_NominaTblCatPeriodos_IDPeriodoPago]
GO
ALTER TABLE [Nomina].[tblCatFondosAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblCatFondosAhorro_NominaTblCatTipoNomina_IDTipoNomina] FOREIGN KEY([IDTipoNomina])
REFERENCES [Nomina].[tblCatTipoNomina] ([IDTipoNomina])
GO
ALTER TABLE [Nomina].[tblCatFondosAhorro] CHECK CONSTRAINT [Fk_NominaTblCatFondosAhorro_NominaTblCatTipoNomina_IDTipoNomina]
GO
