USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblDepartamentoEmpleado](
	[IDDepartamentoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDDepartamento] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
 CONSTRAINT [PK_RHTblDepartamentoEmpleado_IDDepartamentoEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDDepartamentoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDepartamentoEmpleado_FechaFin] ON [RH].[tblDepartamentoEmpleado]
(
	[FechaFin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDepartamentoEmpleado_FechaIni] ON [RH].[tblDepartamentoEmpleado]
(
	[FechaIni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDepartamentoEmpleado_IDDepartamento] ON [RH].[tblDepartamentoEmpleado]
(
	[IDDepartamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDepartamentoEmpleado_IDEmpleado] ON [RH].[tblDepartamentoEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblDepartamentoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatDepartamentos_RHtblDepartamentoEmpleado_IDDepartamento] FOREIGN KEY([IDDepartamento])
REFERENCES [RH].[tblCatDepartamentos] ([IDDepartamento])
GO
ALTER TABLE [RH].[tblDepartamentoEmpleado] CHECK CONSTRAINT [FK_RHtblCatDepartamentos_RHtblDepartamentoEmpleado_IDDepartamento]
GO
ALTER TABLE [RH].[tblDepartamentoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_RHtblDepartamentoEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblDepartamentoEmpleado] CHECK CONSTRAINT [FK_RHtblEmpleados_RHtblDepartamentoEmpleado_IDEmpleado]
GO
