USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblPruebasEmpleados](
	[IDPruebaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDPrueba] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [PK_SaludTblPruebasEmpleados_IDPruebaEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDPruebaEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblPruebasEmpleados] ADD  CONSTRAINT [D_SaludTblPruebasEmpleados_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Salud].[tblPruebasEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_SaludTblPruebasEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Salud].[tblPruebasEmpleados] CHECK CONSTRAINT [FK_RHTblEmpleados_SaludTblPruebasEmpleados_IDEmpleado]
GO
ALTER TABLE [Salud].[tblPruebasEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_SaludTblPruebas_SaludTblPruebasEmpleados_IDPrueba] FOREIGN KEY([IDPrueba])
REFERENCES [Salud].[tblPruebas] ([IDPrueba])
GO
ALTER TABLE [Salud].[tblPruebasEmpleados] CHECK CONSTRAINT [FK_SaludTblPruebas_SaludTblPruebasEmpleados_IDPrueba]
GO
ALTER TABLE [Salud].[tblPruebasEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_SaludTblPruebasEmpleados_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Salud].[tblPruebasEmpleados] CHECK CONSTRAINT [Fk_SaludTblPruebasEmpleados_SeguridadTblUsuarios_IDUsuario]
GO
