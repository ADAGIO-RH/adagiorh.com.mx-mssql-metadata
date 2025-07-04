USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblJefesEmpleados](
	[IDJefeEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDJefe] [int] NOT NULL,
	[FechaReg] [datetime] NULL,
	[Nivel] [int] NULL,
	[IDOrganigrama] [int] NULL,
 CONSTRAINT [Pk_RHTblJefesEmpleados_IDJefeEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDJefeEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblJefesEmpleados_RHTblEmpleados_IDEmpleado_IDJefe] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[IDJefe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblJefesEmpleados_IDEmpleado] ON [RH].[tblJefesEmpleados]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblJefesEmpleados_IDJefe] ON [RH].[tblJefesEmpleados]
(
	[IDJefe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblJefesEmpleados] ADD  CONSTRAINT [D_RHTblJefesEmpleados_FechaReg]  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [RH].[tblJefesEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_rhtbleJefesEmpleados_rh.tblCatOrganigramas_IDOrganigrama] FOREIGN KEY([IDOrganigrama])
REFERENCES [RH].[tblCatOrganigramas] ([IDOrganigrama])
GO
ALTER TABLE [RH].[tblJefesEmpleados] CHECK CONSTRAINT [FK_rhtbleJefesEmpleados_rh.tblCatOrganigramas_IDOrganigrama]
GO
ALTER TABLE [RH].[tblJefesEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblJefesEmpleados_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblJefesEmpleados] CHECK CONSTRAINT [Fk_RHTblJefesEmpleados_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [RH].[tblJefesEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblJefesEmpleados_RHTblEmpleados_IDJefe] FOREIGN KEY([IDJefe])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblJefesEmpleados] CHECK CONSTRAINT [Fk_RHTblJefesEmpleados_RHTblEmpleados_IDJefe]
GO
