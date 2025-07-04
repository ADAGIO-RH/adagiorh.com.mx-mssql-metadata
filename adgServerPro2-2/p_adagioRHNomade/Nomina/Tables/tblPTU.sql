USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblPTU](
	[IDPTU] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpresa] [int] NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[ConceptosIntegranSueldo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[DiasDescontar] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescontarIncapacidades] [bit] NULL,
	[TiposIncapacidadesADescontar] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CantidadGanancia] [decimal](18, 2) NULL,
	[CantidadRepartir] [decimal](18, 2) NULL,
	[CantidadPendiente] [decimal](18, 2) NULL,
	[DiasMinimosTrabajados] [int] NULL,
	[EjercicioPago] [int] NOT NULL,
	[IDPeriodo] [int] NULL,
	[MontoSueldo] [decimal](18, 2) NULL,
	[MontoDias] [decimal](18, 2) NULL,
	[FactorSueldo] [decimal](18, 9) NULL,
	[FactorDias] [decimal](18, 9) NULL,
	[IDEmpleadoTipoSalarioMensualConfianza] [int] NULL,
	[TopeSalarioMensualConfianza] [decimal](18, 2) NULL,
	[TopeConfianza] [decimal](18, 2) NULL,
	[AplicarReforma] [bit] NULL,
	[AplicarPTUFinanciero] [bit] NULL,
 CONSTRAINT [PK_NominaTblPTU_IDPTU] PRIMARY KEY CLUSTERED 
(
	[IDPTU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_NominaTblPTU_IDEmpresaEjercicio] UNIQUE NONCLUSTERED 
(
	[IDEmpresa] ASC,
	[Ejercicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblPTU] ADD  CONSTRAINT [D_NominaTblPTU_DescontarIncapacidades]  DEFAULT (CONVERT([bit],(0))) FOR [DescontarIncapacidades]
GO
ALTER TABLE [Nomina].[tblPTU] ADD  CONSTRAINT [D_NominaTblPTU_DiasMinimosTrabajados]  DEFAULT ((0)) FOR [DiasMinimosTrabajados]
GO
ALTER TABLE [Nomina].[tblPTU] ADD  CONSTRAINT [D_NominaTblPTU_MontoSueldo]  DEFAULT ((0)) FOR [MontoSueldo]
GO
ALTER TABLE [Nomina].[tblPTU] ADD  CONSTRAINT [D_NominaTblPTU_MontoDias]  DEFAULT ((0)) FOR [MontoDias]
GO
ALTER TABLE [Nomina].[tblPTU] ADD  CONSTRAINT [D_NominaTblPTU_FactorSueldo]  DEFAULT ((0)) FOR [FactorSueldo]
GO
ALTER TABLE [Nomina].[tblPTU] ADD  CONSTRAINT [D_NominaTblPTU_FactorDias]  DEFAULT ((0)) FOR [FactorDias]
GO
ALTER TABLE [Nomina].[tblPTU] ADD  CONSTRAINT [D_NominaTblPTU_TopeSalarioMensualConfianza]  DEFAULT ((0)) FOR [TopeSalarioMensualConfianza]
GO
ALTER TABLE [Nomina].[tblPTU] ADD  CONSTRAINT [d_NominaTblPTU_AplicarReforma]  DEFAULT ((0)) FOR [AplicarReforma]
GO
ALTER TABLE [Nomina].[tblPTU]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblPTU_NominaTblCatPeriodos_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblPTU] CHECK CONSTRAINT [FK_NominaTblPTU_NominaTblCatPeriodos_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblPTU]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblPTU_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleadoTipoSalarioMensualConfianza])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblPTU] CHECK CONSTRAINT [Fk_NominaTblPTU_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [Nomina].[tblPTU]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpresa_NominaTblPtu_IDEmpresa] FOREIGN KEY([IDEmpresa])
REFERENCES [RH].[tblEmpresa] ([IdEmpresa])
GO
ALTER TABLE [Nomina].[tblPTU] CHECK CONSTRAINT [FK_RHtblEmpresa_NominaTblPtu_IDEmpresa]
GO
