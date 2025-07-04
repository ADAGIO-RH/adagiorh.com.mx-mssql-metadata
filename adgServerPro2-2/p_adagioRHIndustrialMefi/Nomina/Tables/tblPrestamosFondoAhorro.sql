USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblPrestamosFondoAhorro](
	[IDPrestamoFondoAhorro] [int] IDENTITY(1,1) NOT NULL,
	[IDFondoAhorro] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Monto] [decimal](18, 2) NOT NULL,
	[FechaHora] [datetime] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDPrestamo] [int] NOT NULL,
 CONSTRAINT [Pk_NominaTblPrestamosFondoAhorro_IDFondoAhorro] PRIMARY KEY CLUSTERED 
(
	[IDPrestamoFondoAhorro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblPrestamosFondoAhorro_IDEmpleado] ON [Nomina].[tblPrestamosFondoAhorro]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblPrestamosFondoAhorro_IDFondoAhorro] ON [Nomina].[tblPrestamosFondoAhorro]
(
	[IDFondoAhorro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblPrestamosFondoAhorro_IDPrestamo] ON [Nomina].[tblPrestamosFondoAhorro]
(
	[IDPrestamo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblPrestamosFondoAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblPrestamosFondoAhorro_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Nomina].[tblPrestamosFondoAhorro] CHECK CONSTRAINT [Fk_NominaTblPrestamosFondoAhorro_IDEmpleado]
GO
ALTER TABLE [Nomina].[tblPrestamosFondoAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblPrestamosFondoAhorro_IDFondoAhorro] FOREIGN KEY([IDFondoAhorro])
REFERENCES [Nomina].[tblCatFondosAhorro] ([IDFondoAhorro])
GO
ALTER TABLE [Nomina].[tblPrestamosFondoAhorro] CHECK CONSTRAINT [Fk_NominaTblPrestamosFondoAhorro_IDFondoAhorro]
GO
ALTER TABLE [Nomina].[tblPrestamosFondoAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblPrestamosFondoAhorro_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Nomina].[tblPrestamosFondoAhorro] CHECK CONSTRAINT [Fk_NominaTblPrestamosFondoAhorro_IDUsuario]
GO
ALTER TABLE [Nomina].[tblPrestamosFondoAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblPrestamosFondoAhorro_NominaTblPrestamos_IDPrestamos] FOREIGN KEY([IDPrestamo])
REFERENCES [Nomina].[tblPrestamos] ([IDPrestamo])
GO
ALTER TABLE [Nomina].[tblPrestamosFondoAhorro] CHECK CONSTRAINT [Fk_NominaTblPrestamosFondoAhorro_NominaTblPrestamos_IDPrestamos]
GO
