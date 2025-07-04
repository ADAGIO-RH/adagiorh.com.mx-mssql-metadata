USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblRetirosFondoAhorro](
	[IDRetiroFondoAhorro] [int] IDENTITY(1,1) NOT NULL,
	[IDFondoAhorro] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[MontoEmpresa] [decimal](18, 2) NOT NULL,
	[MontoTrabajador] [decimal](18, 2) NOT NULL,
	[IDPeriodo] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
 CONSTRAINT [Pk_NominaTblRetirosFondoAhorro_IDRetiroFondoAhorro] PRIMARY KEY CLUSTERED 
(
	[IDRetiroFondoAhorro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblRetirosFondoAhorro_IDEmpleado] ON [Nomina].[tblRetirosFondoAhorro]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblRetirosFondoAhorro_IDFondoAhorro] ON [Nomina].[tblRetirosFondoAhorro]
(
	[IDFondoAhorro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblRetirosFondoAhorro_IDPeriodo] ON [Nomina].[tblRetirosFondoAhorro]
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblRetirosFondoAhorro] ADD  CONSTRAINT [D_NominaTblRetirosFondoAhorro]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Nomina].[tblRetirosFondoAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblRetirosFondoAhorro_NominaTblCatFondosAhorro_IDFondoAhorro] FOREIGN KEY([IDFondoAhorro])
REFERENCES [Nomina].[tblCatFondosAhorro] ([IDFondoAhorro])
GO
ALTER TABLE [Nomina].[tblRetirosFondoAhorro] CHECK CONSTRAINT [Fk_NominaTblRetirosFondoAhorro_NominaTblCatFondosAhorro_IDFondoAhorro]
GO
ALTER TABLE [Nomina].[tblRetirosFondoAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblRetirosFondoAhorro_NominaTblCatPeriodos_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblRetirosFondoAhorro] CHECK CONSTRAINT [Fk_NominaTblRetirosFondoAhorro_NominaTblCatPeriodos_IDPeriodo]
GO
ALTER TABLE [Nomina].[tblRetirosFondoAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblRetirosFondoAhorro_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblRetirosFondoAhorro] CHECK CONSTRAINT [Fk_NominaTblRetirosFondoAhorro_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [Nomina].[tblRetirosFondoAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblRetirosFondoAhorro_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Nomina].[tblRetirosFondoAhorro] CHECK CONSTRAINT [Fk_NominaTblRetirosFondoAhorro_SeguridadTblUsuarios_IDUsuario]
GO
