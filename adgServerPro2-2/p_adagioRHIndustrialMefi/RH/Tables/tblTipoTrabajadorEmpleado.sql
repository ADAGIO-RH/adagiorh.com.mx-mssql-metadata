USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblTipoTrabajadorEmpleado](
	[IDTipoTrabajadorEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoTrabajador] [int] NULL,
	[IDTipoContrato] [int] NULL,
	[IDTipoSalario] [int] NULL,
	[IDTipoPension] [int] NULL,
 CONSTRAINT [PK_RHTblTipoTrabajadorEmpleado_IDTipoTrabajadorEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDTipoTrabajadorEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblTipoTrabajadorEmpleado_IDEmpleado] ON [RH].[tblTipoTrabajadorEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblTipoTrabajadorEmpleado_IDTipoContrato] ON [RH].[tblTipoTrabajadorEmpleado]
(
	[IDTipoContrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblTipoTrabajadorEmpleado_IDTipoTrabajador] ON [RH].[tblTipoTrabajadorEmpleado]
(
	[IDTipoTrabajador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_IMSSTblCatTipoPension_RHTblTipoTrabajadorEmpleado_IDTipoPension] FOREIGN KEY([IDTipoPension])
REFERENCES [IMSS].[tblCatTipoPension] ([IDTipoPension])
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado] CHECK CONSTRAINT [FK_IMSSTblCatTipoPension_RHTblTipoTrabajadorEmpleado_IDTipoPension]
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_IMSStblCatTipoSalario_RHtblTipoTrabajadorEmpleado_IDTipoSalario] FOREIGN KEY([IDTipoSalario])
REFERENCES [IMSS].[tblCatTipoSalario] ([IDTipoSalario])
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado] CHECK CONSTRAINT [FK_IMSStblCatTipoSalario_RHtblTipoTrabajadorEmpleado_IDTipoSalario]
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_IMSStblCatTipoTrabajador_RHtblTipoTrabajadorEmpleado_IDTipoTrabajador] FOREIGN KEY([IDTipoTrabajador])
REFERENCES [IMSS].[tblCatTipoTrabajador] ([IDTipoTrabajador])
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado] CHECK CONSTRAINT [FK_IMSStblCatTipoTrabajador_RHtblTipoTrabajadorEmpleado_IDTipoTrabajador]
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_RHtblTipoTrabajadorEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado] CHECK CONSTRAINT [FK_RHtblEmpleados_RHtblTipoTrabajadorEmpleado_IDEmpleado]
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SATCatTipoContrato_RHtblTipoTrabajadorEmpleado_IDTipoContrato] FOREIGN KEY([IDTipoContrato])
REFERENCES [Sat].[tblCatTiposContrato] ([IDTipoContrato])
GO
ALTER TABLE [RH].[tblTipoTrabajadorEmpleado] CHECK CONSTRAINT [FK_SATCatTipoContrato_RHtblTipoTrabajadorEmpleado_IDTipoContrato]
GO
