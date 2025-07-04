USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlFiniquitos](
	[IDFiniquito] [int] IDENTITY(1,1) NOT NULL,
	[IDPeriodo] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[FechaBaja] [date] NOT NULL,
	[DiasVacaciones] [decimal](18, 2) NULL,
	[DiasAguinaldo] [decimal](18, 2) NULL,
	[DiasIndemnizacion90Dias] [decimal](18, 2) NULL,
	[DiasIndemnizacion20Dias] [decimal](18, 2) NULL,
	[AplicarBaja] [bit] NOT NULL,
	[IDEStatusFiniquito] [int] NOT NULL,
	[FechaAntiguedad] [date] NULL,
	[DiasDePago] [decimal](18, 2) NULL,
	[DiasPorPrimaAntiguedad] [decimal](18, 2) NULL,
	[SueldoFiniquito] [decimal](18, 2) NULL,
	[FechaAplicado] [date] NULL,
	[IDMovAfiliatorio] [int] NULL,
 CONSTRAINT [PK_NominaTblControlFiniquito_IDFiniquito] PRIMARY KEY CLUSTERED 
(
	[IDFiniquito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblControlFiniquito_IDEmpleado_IDPeriodo] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblControlFiniquitos_IDEmpleado] ON [Nomina].[tblControlFiniquitos]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblControlFiniquitos_IDEstatusFiniquito] ON [Nomina].[tblControlFiniquitos]
(
	[IDEStatusFiniquito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblControlFiniquitos_IDPeriodo] ON [Nomina].[tblControlFiniquitos]
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlFiniquitos] ADD  CONSTRAINT [DF_NominaTblControlFiniquito_FechaBaja]  DEFAULT (getdate()) FOR [FechaBaja]
GO
ALTER TABLE [Nomina].[tblControlFiniquitos] ADD  DEFAULT ((0)) FOR [AplicarBaja]
GO
ALTER TABLE [Nomina].[tblControlFiniquitos]  WITH CHECK ADD  CONSTRAINT [FK_IMSSTblMovAfiliatorios_NominaTblControlFiniquito_IDMovAfiliatorio] FOREIGN KEY([IDMovAfiliatorio])
REFERENCES [IMSS].[tblMovAfiliatorios] ([IDMovAfiliatorio])
GO
ALTER TABLE [Nomina].[tblControlFiniquitos] CHECK CONSTRAINT [FK_IMSSTblMovAfiliatorios_NominaTblControlFiniquito_IDMovAfiliatorio]
GO
ALTER TABLE [Nomina].[tblControlFiniquitos]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatEstatusFiniquito_NominaTblControlFiniquito_IDEStatusFiniquito] FOREIGN KEY([IDEStatusFiniquito])
REFERENCES [Nomina].[tblCatEstatusFiniquito] ([IDEStatusFiniquito])
GO
ALTER TABLE [Nomina].[tblControlFiniquitos] CHECK CONSTRAINT [FK_NominaTblCatEstatusFiniquito_NominaTblControlFiniquito_IDEStatusFiniquito]
GO
ALTER TABLE [Nomina].[tblControlFiniquitos]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatPeriodos_NominaTblControlFiniquitos_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblControlFiniquitos] CHECK CONSTRAINT [FK_NominaTblCatPeriodos_NominaTblControlFiniquitos_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblControlFiniquitos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleado_NominaTblControlFiniquito_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblControlFiniquitos] CHECK CONSTRAINT [FK_RHTblEmpleado_NominaTblControlFiniquito_IDEmpleado]
GO
