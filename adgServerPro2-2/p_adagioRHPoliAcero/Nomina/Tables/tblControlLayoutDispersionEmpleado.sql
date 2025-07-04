USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlLayoutDispersionEmpleado](
	[IDControlLayoutDispersionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDPeriodo] [int] NOT NULL,
	[IDLayoutPago] [int] NOT NULL,
	[IDBanco] [int] NULL,
	[CuentaBancaria] [varchar](18) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_NominaTblControlLayoutDispersionEmpleado_IDControlLayoutDispersionEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDControlLayoutDispersionEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblControlLayoutDispersionEmpleado_IDEmpleado_IDPeriodo_IDLayoutPago] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[IDPeriodo] ASC,
	[IDLayoutPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblControlLayoutDispersionEmpleado_IDEmpleado] ON [Nomina].[tblControlLayoutDispersionEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblControlLayoutDispersionEmpleado_IDLayoutPago] ON [Nomina].[tblControlLayoutDispersionEmpleado]
(
	[IDLayoutPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblControlLayoutDispersionEmpleado_IDPeriodo] ON [Nomina].[tblControlLayoutDispersionEmpleado]
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlLayoutDispersionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatPeriodos_NominaTblControlLayoutDispersionEmpleado_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblControlLayoutDispersionEmpleado] CHECK CONSTRAINT [FK_NominaTblCatPeriodos_NominaTblControlLayoutDispersionEmpleado_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblControlLayoutDispersionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblLayoutPago_NominaTblControlLayoutDispersionEmpleado_IDLayoutPago] FOREIGN KEY([IDLayoutPago])
REFERENCES [Nomina].[tblLayoutPago] ([IDLayoutPago])
GO
ALTER TABLE [Nomina].[tblControlLayoutDispersionEmpleado] CHECK CONSTRAINT [FK_NominaTblLayoutPago_NominaTblControlLayoutDispersionEmpleado_IDLayoutPago]
GO
ALTER TABLE [Nomina].[tblControlLayoutDispersionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_NominaTblControlLayoutDispersionEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblControlLayoutDispersionEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_NominaTblControlLayoutDispersionEmpleado_IDEmpleado]
GO
ALTER TABLE [Nomina].[tblControlLayoutDispersionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatBancos_NominaTblControlLayoutDispersionEmpleado] FOREIGN KEY([IDBanco])
REFERENCES [Sat].[tblCatBancos] ([IDBanco])
GO
ALTER TABLE [Nomina].[tblControlLayoutDispersionEmpleado] CHECK CONSTRAINT [FK_SatTblCatBancos_NominaTblControlLayoutDispersionEmpleado]
GO
