USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblPTUEmpleados](
	[IDPTUEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDPTU] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[SalarioDiario] [decimal](18, 2) NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[Sindical] [bit] NOT NULL,
	[SalarioAcumuladoReal] [decimal](18, 2) NOT NULL,
	[SalarioAcumuladoTopado] [decimal](18, 2) NOT NULL,
	[DiasVigencia] [int] NOT NULL,
	[DiasADescontar] [int] NULL,
	[Incapacidades] [int] NULL,
	[DiasTrabajados] [int] NOT NULL,
	[PTUPorSalario] [decimal](18, 2) NOT NULL,
	[PTUPorDias] [decimal](18, 2) NOT NULL,
	[TotalPTU]  AS ([PTUPorSalario]+[PTUPorDias]),
	[PromedioSueldo3Meses] [decimal](18, 2) NULL,
	[PromedioPTU3Anios] [decimal](18, 2) NULL,
	[PTURecomendado] [decimal](18, 2) NULL,
	[PTUFinanciero] [decimal](18, 2) NULL,
 CONSTRAINT [Pk_NominaTblPTUEmpleados_IDPTUEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDPTUEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblPTUEmpleados] ADD  CONSTRAINT [D_NominaTblPTUEmpleados_SalarioDiario]  DEFAULT ((0)) FOR [SalarioDiario]
GO
ALTER TABLE [Nomina].[tblPTUEmpleados] ADD  CONSTRAINT [D_NominaTblPTUEmpleados_Sindical]  DEFAULT ((0)) FOR [Sindical]
GO
ALTER TABLE [Nomina].[tblPTUEmpleados] ADD  CONSTRAINT [D_NominaTblPTUEmpleados_DiasADescontar]  DEFAULT ((0)) FOR [DiasADescontar]
GO
ALTER TABLE [Nomina].[tblPTUEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblPTU_NominaTblPTUEmpleados_IDPTU] FOREIGN KEY([IDPTU])
REFERENCES [Nomina].[tblPTU] ([IDPTU])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblPTUEmpleados] CHECK CONSTRAINT [FK_NominaTblPTU_NominaTblPTUEmpleados_IDPTU]
GO
ALTER TABLE [Nomina].[tblPTUEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_NominaTblPTUEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblPTUEmpleados] CHECK CONSTRAINT [FK_RHTblEmpleados_NominaTblPTUEmpleados_IDEmpleado]
GO
