USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[TblVigenciaEmpleado](
	[IDEmpleado] [int] NOT NULL,
	[FechaAlta] [date] NULL,
	[FechaBaja] [date] NULL,
	[FechaReingreso] [date] NULL,
	[IDMovAfiliatorio] [int] NULL,
	[SalarioDiario] [decimal](21, 2) NULL,
	[SalarioVariable] [decimal](21, 2) NULL,
	[SalarioIntegrado] [decimal](21, 2) NULL,
	[SalarioDiarioReal] [decimal](21, 2) NULL,
	[FechaReingresoAntiguedad] [date] NULL,
 CONSTRAINT [U_IMSSTblVigenciaEmpleado_IDEmpleado] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_IMSSTblVigenciaEmpleado_IDEmpleado] ON [IMSS].[TblVigenciaEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [IMSS].[TblVigenciaEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_IMSSTblVigenciaEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [IMSS].[TblVigenciaEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_IMSSTblVigenciaEmpleado_IDEmpleado]
GO
