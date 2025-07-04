USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblHistorialesEmpleadosPeriodos](
	[IDHistorialEmpleadoPeriodo] [int] IDENTITY(1,1) NOT NULL,
	[IDPeriodo] [int] NULL,
	[IDEmpleado] [int] NULL,
	[IDCentroCosto] [int] NULL,
	[IDDepartamento] [int] NULL,
	[IDSucursal] [int] NULL,
	[IDPuesto] [int] NULL,
	[IDRegPatronal] [int] NULL,
	[IDCliente] [int] NULL,
	[IDEmpresa] [int] NULL,
	[IDArea] [int] NULL,
	[IDDivision] [int] NULL,
	[IDClasificacionCorporativa] [int] NULL,
	[IDRegion] [int] NULL,
	[IDRazonSocial] [int] NULL,
	[Asimilado] [bit] NULL,
 CONSTRAINT [PK_NominatblHistorialesEmpleadosPeriodos_IDHistorialEmpleadoPeriodo] PRIMARY KEY CLUSTERED 
(
	[IDHistorialEmpleadoPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [u_NominatblHistorialesEmpleadosPeriodos_IDPeriodoIDEmpleadoAsimilado] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[IDPeriodo] ASC,
	[Asimilado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDArea] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDArea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDCentroCosto] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDCentroCosto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDClasificaciónCorporativa] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDClasificacionCorporativa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDCliente] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDDepartamento] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDDepartamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDDivision] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDDivision] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDEmpleado] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDEmpresa] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDEmpresa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDPeriodo] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDPuesto] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDPuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDRazonSocial] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDRazonSocial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDRegion] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDRegion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDRegPatronal] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDRegPatronal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblHistorialesEmpleadosPeriodos_IDSucursal] ON [Nomina].[tblHistorialesEmpleadosPeriodos]
(
	[IDSucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] ADD  CONSTRAINT [d_NominatblHistorialesEmpleadosPeriodos_Asimilados]  DEFAULT ((0)) FOR [Asimilado]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatPeriodos_NominatblHistorialesEmpleadosPeriodos_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_NominaTblCatPeriodos_NominatblHistorialesEmpleadosPeriodos_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatArea_NominatblHistorialesEmpleadosPeriodos_IDArea] FOREIGN KEY([IDArea])
REFERENCES [RH].[tblCatArea] ([IDArea])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHTblCatArea_NominatblHistorialesEmpleadosPeriodos_IDArea]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatCentroCosto_NominatblHistorialesEmpleadosPeriodos_IDCentroCosto] FOREIGN KEY([IDCentroCosto])
REFERENCES [RH].[tblCatCentroCosto] ([IDCentroCosto])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHtblCatCentroCosto_NominatblHistorialesEmpleadosPeriodos_IDCentroCosto]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatClasificacionesCorporativas_NominatblHistorialesEmpleadosPeriodos_IDClasificacionCorporativa] FOREIGN KEY([IDClasificacionCorporativa])
REFERENCES [RH].[tblCatClasificacionesCorporativas] ([IDClasificacionCorporativa])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHtblCatClasificacionesCorporativas_NominatblHistorialesEmpleadosPeriodos_IDClasificacionCorporativa]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatClientes_NominatblHistorialesEmpleadosPeriodos_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHtblCatClientes_NominatblHistorialesEmpleadosPeriodos_IDCliente]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatDepartamentos_NominatblHistorialesEmpleadosPeriodos_IDDepartamento] FOREIGN KEY([IDDepartamento])
REFERENCES [RH].[tblCatDepartamentos] ([IDDepartamento])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHTblCatDepartamentos_NominatblHistorialesEmpleadosPeriodos_IDDepartamento]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatDivisiones_NominatblHistorialesEmpleadosPeriodos_IDDivision] FOREIGN KEY([IDDivision])
REFERENCES [RH].[tblCatDivisiones] ([IDDivision])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHTblCatDivisiones_NominatblHistorialesEmpleadosPeriodos_IDDivision]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatPuestos_NominatblHistorialesEmpleadosPeriodos_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHtblCatPuestos_NominatblHistorialesEmpleadosPeriodos_IDPuesto]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatRazonesSociales_NominatblHistorialesEmpleadosPeriodos_IDRazonSocial] FOREIGN KEY([IDRazonSocial])
REFERENCES [RH].[tblCatRazonesSociales] ([IDRazonSocial])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHtblCatRazonesSociales_NominatblHistorialesEmpleadosPeriodos_IDRazonSocial]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRegiones_NominatblHistorialesEmpleadosPeriodos_IDRegion] FOREIGN KEY([IDRegion])
REFERENCES [RH].[tblCatRegiones] ([IDRegion])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHTblCatRegiones_NominatblHistorialesEmpleadosPeriodos_IDRegion]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRegPatronal_NominatblHistorialesEmpleadosPeriodos_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHTblCatRegPatronal_NominatblHistorialesEmpleadosPeriodos_IDRegPatronal]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatSurcursales_NominatblHistorialesEmpleadosPeriodos_IDSucursal] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHtblCatSurcursales_NominatblHistorialesEmpleadosPeriodos_IDSucursal]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_NominatblHistorialesEmpleadosPeriodos_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHtblEmpleados_NominatblHistorialesEmpleadosPeriodos_IDEmpleado]
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpresa_NominatblHistorialesEmpleadosPeriodos_IDEmpresa] FOREIGN KEY([IDEmpresa])
REFERENCES [RH].[tblEmpresa] ([IdEmpresa])
GO
ALTER TABLE [Nomina].[tblHistorialesEmpleadosPeriodos] CHECK CONSTRAINT [FK_RHtblEmpresa_NominatblHistorialesEmpleadosPeriodos_IDEmpresa]
GO
