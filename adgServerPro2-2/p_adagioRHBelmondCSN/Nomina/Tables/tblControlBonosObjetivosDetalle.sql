USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlBonosObjetivosDetalle](
	[IDControlBonosObjetivosDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDControlBonosObjetivos] [int] NOT NULL,
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
	[CalibracionNivelSalarial] [int] NULL,
	[Dias] [int] NULL,
	[CalibracionDias] [int] NULL,
	[Incapacidades] [int] NULL,
	[CalibracionIncapacidades] [int] NULL,
	[Ausentismos] [int] NULL,
	[CalibracionAusentismos] [int] NULL,
	[DiasEjercicio] [int] NULL,
	[CalibracionDiasEjercicio] [int] NULL,
	[TotalEvaluacionPorcentual] [decimal](18, 4) NULL,
	[CalibracionTotalEvaluacionPorcentual] [decimal](18, 4) NULL,
	[TotalObjetivos] [decimal](18, 4) NULL,
	[CalibracionTotalObjetivos] [decimal](18, 4) NULL,
	[FactorObjetivos] [decimal](18, 4) NULL,
	[CalibracionFactorObjetivos] [decimal](18, 4) NULL,
	[SueldoActual] [decimal](18, 2) NULL,
	[SueldoActualMensual] [decimal](18, 2) NULL,
	[SueldoActualAnual] [decimal](18, 2) NULL,
	[FactorParaBono] [decimal](18, 4) NULL,
	[CalibracionFactorParaBono] [decimal](18, 4) NULL,
	[ResultadoUtilidadDesempeno] [decimal](18, 4) NULL,
	[CalibracionResultadoUtilidadDesempeno] [decimal](18, 4) NULL,
	[BonoAnual] [decimal](18, 2) NULL,
	[CalibracionBonoAnual] [decimal](18, 2) NULL,
	[PTU] [decimal](18, 2) NULL,
	[CalibracionPTU] [decimal](18, 2) NULL,
	[Complemento] [decimal](18, 2) NULL,
	[CalibracionComplemento] [decimal](18, 2) NULL,
	[BonoFinal] [decimal](18, 2) NULL,
	[CalibracionBonoFinal] [decimal](18, 2) NULL,
	[ExcluirColaborador] [int] NULL,
 CONSTRAINT [PK_NominaTblControlBonosObjetivosDetalle_IDControlBonosObjetivosDetalle] PRIMARY KEY CLUSTERED 
(
	[IDControlBonosObjetivosDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblControlBonosObjetivosDetalle_IDEmpleado_IDControlBonosObjetivos] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[IDControlBonosObjetivos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlBonosObjetivosDetalle_NominaTblControlBonosObjetivos] FOREIGN KEY([IDControlBonosObjetivos])
REFERENCES [Nomina].[tblControlBonosObjetivos] ([IDControlBonosObjetivos])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_NominaTblControlBonosObjetivosDetalle_NominaTblControlBonosObjetivos]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatArea_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDArea])
REFERENCES [RH].[tblCatArea] ([IDArea])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatArea_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatCentroCosto_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDCentroCosto])
REFERENCES [RH].[tblCatCentroCosto] ([IDCentroCosto])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatCentroCosto_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatClientes_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatClientes_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatDepartamentos_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDDepartamento])
REFERENCES [RH].[tblCatDepartamentos] ([IDDepartamento])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatDepartamentos_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatDivisiones_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDDivision])
REFERENCES [RH].[tblCatDivisiones] ([IDDivision])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatDivisiones_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatPuestos_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatPuestos_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatRegiones_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDRegion])
REFERENCES [RH].[tblCatRegiones] ([IDRegion])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatRegiones_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatRegPatronal_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatRegPatronal_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatSucursales_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatSucursales_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatTiposPrestaciones_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDTipoPrestacion])
REFERENCES [RH].[tblCatTiposPrestaciones] ([IDTipoPrestacion])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblCatTiposPrestaciones_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHTblEmpleados_NominaTblControlBonosObjetivosDetalle]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpresa_NominaTblControlBonosObjetivosDetalle] FOREIGN KEY([IDEmpresa])
REFERENCES [RH].[tblEmpresa] ([IdEmpresa])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosDetalle] CHECK CONSTRAINT [FK_RHtblEmpresa_NominaTblControlBonosObjetivosDetalle]
GO
