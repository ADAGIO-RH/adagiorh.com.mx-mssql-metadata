USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCentroCostoEmpleado](
	[IDCentroCostoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDCentroCosto] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
 CONSTRAINT [PK_RHtblCentroCostoEmpleado_IDCentroCostoEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDCentroCostoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblCentroCostoEmpleado_FechaFin] ON [RH].[tblCentroCostoEmpleado]
(
	[FechaFin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblCentroCostoEmpleado_FechaIni] ON [RH].[tblCentroCostoEmpleado]
(
	[FechaIni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblCentroCostoEmpleado_IDCentroCosto] ON [RH].[tblCentroCostoEmpleado]
(
	[IDCentroCosto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblCentroCostoEmpleado_IDEmpleado] ON [RH].[tblCentroCostoEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCentroCostoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatCentroCosto_RHtblCentroCostoEmpleado_IDCentroCosto] FOREIGN KEY([IDCentroCosto])
REFERENCES [RH].[tblCatCentroCosto] ([IDCentroCosto])
GO
ALTER TABLE [RH].[tblCentroCostoEmpleado] CHECK CONSTRAINT [FK_RHTblCatCentroCosto_RHtblCentroCostoEmpleado_IDCentroCosto]
GO
ALTER TABLE [RH].[tblCentroCostoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_RHtblCentroCostoEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblCentroCostoEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_RHtblCentroCostoEmpleado_IDEmpleado]
GO
