USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCajaAhorro](
	[IDCajaAhorro] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Monto] [decimal](18, 2) NOT NULL,
	[IDEstatus] [int] NOT NULL,
 CONSTRAINT [Pk_NominaTblEmpleadosCajaAhorro_IDCajaAhorro] PRIMARY KEY CLUSTERED 
(
	[IDCajaAhorro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominaTblCajaAhorro_IDEmpleado] ON [Nomina].[tblCajaAhorro]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblCajaAhorro] ADD  CONSTRAINT [D_NominaTblEmpleadosCajaAhorro_IDEstatus]  DEFAULT ((1)) FOR [IDEstatus]
GO
ALTER TABLE [Nomina].[tblCajaAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblEmpleadosCajaAhorro_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblCajaAhorro] CHECK CONSTRAINT [Fk_NominaTblEmpleadosCajaAhorro_IDEmpleado]
GO
