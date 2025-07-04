USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[TblControlAumentosDesempenoDetalle](
	[IDControlAumentosDesempenoDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDControlAumentosDesempeno] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoPrestacion] [int] NULL,
	[Antiguedad] [int] NULL,
	[Factor] [decimal](19, 5) NULL,
	[IDRegPatronal] [int] NULL,
	[IDPuesto] [int] NULL,
	[IDDivision] [int] NULL,
	[IDRegion] [int] NULL,
	[IDArea] [int] NULL,
	[IDSucursal] [int] NULL,
	[IDCliente] [int] NULL,
	[IDEmpresa] [int] NULL,
	[IDCentroCosto] [int] NULL,
	[IDDepartamento] [int] NULL,
	[FechaAntiguedad] [date] NULL,
	[NivelSalarial] [int] NULL,
	[NivelSalarialCalibrado] [int] NULL,
	[EvaluacionJefe] [decimal](18, 4) NULL,
	[EvaluacionSubordinados] [decimal](18, 4) NULL,
	[EvaluacionColegas] [decimal](18, 4) NULL,
	[TotalEvaluacionPorcentual] [decimal](18, 4) NULL,
	[TotalEvaluacionPeso] [decimal](18, 4) NULL,
	[TotalEvaluacionCalibrado] [decimal](18, 4) NULL,
	[TotalObjetivosPorPesoEnCicloMedicion] [decimal](18, 4) NULL,
	[TotalObjetivosPeso] [decimal](18, 4) NULL,
	[TotalObjetivosCalibrado] [decimal](18, 4) NULL,
	[SueldoActual] [decimal](18, 2) NULL,
	[SueldoActualMensual] [decimal](18, 2) NULL,
	[PorcentajeIncremento] [decimal](18, 4) NULL,
	[PorcentajeIncrementoCalibrado] [decimal](18, 4) NULL,
	[SueldoNuevoSinTope] [decimal](18, 2) NULL,
	[SueldoMensualNuevoSinTope] [decimal](18, 2) NULL,
	[SueldoNuevoTopado] [decimal](18, 2) NULL,
	[SueldoMensualNuevoTopado] [decimal](18, 2) NULL,
	[PorcentajeIncrementoInverso] [decimal](18, 4) NULL,
	[SueldoNuevo] [decimal](18, 2) NULL,
	[SueldoMensualNuevo] [decimal](18, 2) NULL,
	[SueldoCalibrado] [decimal](18, 2) NULL,
	[SueldoMensualCalibrado] [decimal](18, 2) NULL,
	[ExcluirColaborador] [int] NULL,
	[IDMovAfiliatorio] [int] NULL,
	[SalarioDiarioMovimiento] [decimal](18, 2) NULL,
	[SalarioIntegradoMovimiento] [decimal](18, 2) NULL,
	[SalarioVariableMovimiento] [decimal](18, 2) NULL,
	[SalarioDiarioRealMovimiento] [decimal](18, 2) NULL,
 CONSTRAINT [PK_NominaTblControlAumentosDesempenoDetalle_IDControlAumentosDesempenoDetalle] PRIMARY KEY CLUSTERED 
(
	[IDControlAumentosDesempenoDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblControlAumentosDesempenoDetalle_IDEmpleado_IDControlAumentosDesempeno] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[IDControlAumentosDesempeno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlAumentosDesempenoDetalle_IMSStblMovAfiliatorios_IDMovAfiliatorio] FOREIGN KEY([IDMovAfiliatorio])
REFERENCES [IMSS].[tblMovAfiliatorios] ([IDMovAfiliatorio])
ON DELETE SET NULL
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_NominaTblControlAumentosDesempenoDetalle_IMSStblMovAfiliatorios_IDMovAfiliatorio]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlAumentosDesempenoDetalle_NominaTblControlAumentosDesempeno_IDControlAumentosDesempeno] FOREIGN KEY([IDControlAumentosDesempeno])
REFERENCES [Nomina].[tblControlAumentosDesempeno] ([IDControlAumentosDesempeno])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_NominaTblControlAumentosDesempenoDetalle_NominaTblControlAumentosDesempeno_IDControlAumentosDesempeno]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlAumentosDesempenoDetalle_RHtblCatTiposPrestaciones_IDTipoPrestacion] FOREIGN KEY([IDTipoPrestacion])
REFERENCES [RH].[tblCatTiposPrestaciones] ([IDTipoPrestacion])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_NominaTblControlAumentosDesempenoDetalle_RHtblCatTiposPrestaciones_IDTipoPrestacion]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatArea_NominaTblControlAumentosDesempenoDetalle_IDArea] FOREIGN KEY([IDArea])
REFERENCES [RH].[tblCatArea] ([IDArea])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblCatArea_NominaTblControlAumentosDesempenoDetalle_IDArea]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatCentroCosto_NominaTblControlAumentosDesempenoDetalle_IDCentroCosto] FOREIGN KEY([IDCentroCosto])
REFERENCES [RH].[tblCatCentroCosto] ([IDCentroCosto])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblCatCentroCosto_NominaTblControlAumentosDesempenoDetalle_IDCentroCosto]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatClientes_NominaTblControlAumentosDesempenoDetalle_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblCatClientes_NominaTblControlAumentosDesempenoDetalle_IDCliente]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatDepartamentos_NominaTblControlAumentosDesempenoDetalle_IDDepartamento] FOREIGN KEY([IDDepartamento])
REFERENCES [RH].[tblCatDepartamentos] ([IDDepartamento])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblCatDepartamentos_NominaTblControlAumentosDesempenoDetalle_IDDepartamento]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatDivisiones_NominaTblControlAumentosDesempenoDetalle_IDDivision] FOREIGN KEY([IDDivision])
REFERENCES [RH].[tblCatDivisiones] ([IDDivision])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblCatDivisiones_NominaTblControlAumentosDesempenoDetalle_IDDivision]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatPuestos_NominaTblControlAumentosDesempenoDetalle_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblCatPuestos_NominaTblControlAumentosDesempenoDetalle_IDPuesto]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatRegiones_NominaTblControlAumentosDesempenoDetalle_IDRegion] FOREIGN KEY([IDRegion])
REFERENCES [RH].[tblCatRegiones] ([IDRegion])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblCatRegiones_NominaTblControlAumentosDesempenoDetalle_IDRegion]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatRegPatronal_NominaTblControlAumentosDesempenoDetalle_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblCatRegPatronal_NominaTblControlAumentosDesempenoDetalle_IDRegPatronal]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatSucursales_NominaTblControlAumentosDesempenoDetalle_IDSucursal] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblCatSucursales_NominaTblControlAumentosDesempenoDetalle_IDSucursal]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_NominaTblControlAumentosDesempenoDetalle_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHTblEmpleados_NominaTblControlAumentosDesempenoDetalle_IDEmpleado]
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpresa_NominaTblControlAumentosDesempenoDetalle_IDEmpresa] FOREIGN KEY([IDEmpresa])
REFERENCES [RH].[tblEmpresa] ([IdEmpresa])
GO
ALTER TABLE [Nomina].[TblControlAumentosDesempenoDetalle] CHECK CONSTRAINT [FK_RHtblEmpresa_NominaTblControlAumentosDesempenoDetalle_IDEmpresa]
GO
