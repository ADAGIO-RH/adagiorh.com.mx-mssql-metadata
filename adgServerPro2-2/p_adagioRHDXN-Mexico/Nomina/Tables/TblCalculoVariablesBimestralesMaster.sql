USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[TblCalculoVariablesBimestralesMaster](
	[IDCalculoVariablesBimestralesMaster] [int] IDENTITY(1,1) NOT NULL,
	[IDControlCalculoVariables] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoPrestacion] [int] NOT NULL,
	[FechaAntiguedad] [date] NOT NULL,
	[VariableCambio] [bit] NULL,
	[FactorCambio] [bit] NULL,
	[IntegradoCambio] [bit] NULL,
	[NuevoFactor] [decimal](18, 5) NULL,
	[FactorAntiguo] [decimal](18, 5) NULL,
	[AniosPrestacion] [int] NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[SalarioVariable] [decimal](18, 2) NULL,
	[SalarioIntegrado] [decimal](18, 2) NULL,
	[SalarioDiarioReal] [decimal](18, 2) NULL,
	[AnteriorSalarioDiario] [decimal](18, 2) NULL,
	[AnteriorSalarioVariable] [decimal](18, 2) NULL,
	[AnteriorSalarioIntegrado] [decimal](18, 2) NULL,
	[AnteriorSalarioDiarioReal] [decimal](18, 2) NULL,
	[Dias] [decimal](18, 2) NULL,
	[DiaAplicacion] [date] NULL,
	[CantidadPremioAsistencia] [decimal](18, 2) NULL,
	[CantidadPremioPuntualidad] [decimal](18, 2) NULL,
	[CantidadValesDespensa] [decimal](18, 2) NULL,
	[CantidadIntegrablesVariables] [decimal](18, 2) NULL,
	[CantidadHorasExtrasDobles] [decimal](18, 2) NULL,
	[UMA] [decimal](18, 2) NULL,
	[SalarioMinimo] [decimal](18, 2) NULL,
	[CriterioDias] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CriterioUMA] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosIntegran] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaUltimoMovimiento] [date] NULL,
	[Afectar] [bit] NULL,
	[IDMovAfiliatorio] [int] NULL,
 CONSTRAINT [PK_NominaTblCalculoVariablesBimestralesMaster_IDCalculoVariablesBimestralesMaster] PRIMARY KEY CLUSTERED 
(
	[IDCalculoVariablesBimestralesMaster] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblCalculoVariablesBimestralesMaster_IDEmpleado_IDControlCalculoVariables] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[IDControlCalculoVariables] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster] ADD  CONSTRAINT [d_NominaTblMasterCalculoVariablesBimestrales_VariableCambio]  DEFAULT ((0)) FOR [VariableCambio]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster] ADD  CONSTRAINT [d_NominaTblMasterCalculoVariablesBimestrales_FactorCambio]  DEFAULT ((0)) FOR [FactorCambio]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster] ADD  CONSTRAINT [d_NominaTblMasterCalculoVariablesBimestrales_IntegradoCambio]  DEFAULT ((0)) FOR [IntegradoCambio]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster] ADD  CONSTRAINT [d_NominaTblMasterCalculoVariablesBimestrales_Afectar]  DEFAULT ((0)) FOR [Afectar]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblCalculoVariablesBimestralesMaster_IMSStblMovAfiliatorios_IDMovAfiliatorio] FOREIGN KEY([IDMovAfiliatorio])
REFERENCES [IMSS].[tblMovAfiliatorios] ([IDMovAfiliatorio])
ON DELETE SET NULL
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster] CHECK CONSTRAINT [Fk_NominaTblCalculoVariablesBimestralesMaster_IMSStblMovAfiliatorios_IDMovAfiliatorio]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlCalculoVariablesBimestrales_NominaTblMasterCalculoVariablesBimestrales_IDControlCalculoVariables] FOREIGN KEY([IDControlCalculoVariables])
REFERENCES [Nomina].[tblControlCalculoVariablesBimestrales] ([IDControlCalculoVariables])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster] CHECK CONSTRAINT [FK_NominaTblControlCalculoVariablesBimestrales_NominaTblMasterCalculoVariablesBimestrales_IDControlCalculoVariables]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlCalculoVariablesBimestrales_RHtblCatTiposPrestaciones_IDTipoPrestacion] FOREIGN KEY([IDTipoPrestacion])
REFERENCES [RH].[tblCatTiposPrestaciones] ([IDTipoPrestacion])
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster] CHECK CONSTRAINT [FK_NominaTblControlCalculoVariablesBimestrales_RHtblCatTiposPrestaciones_IDTipoPrestacion]
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_NominaTblMasterCalculoVariablesBimestrales_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[TblCalculoVariablesBimestralesMaster] CHECK CONSTRAINT [FK_RHTblEmpleados_NominaTblMasterCalculoVariablesBimestrales_IDEmpleado]
GO
