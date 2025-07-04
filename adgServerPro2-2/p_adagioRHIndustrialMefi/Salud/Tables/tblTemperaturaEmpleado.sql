USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblTemperaturaEmpleado](
	[IDTemperaturaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
	[Temperatura] [decimal](18, 2) NOT NULL,
 CONSTRAINT [Pk_SaludTblTemperaturaEmpleado_IDTemperaturaEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDTemperaturaEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblTemperaturaEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_SaludTblTemperaturaEmpleado_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Salud].[tblTemperaturaEmpleado] CHECK CONSTRAINT [Fk_SaludTblTemperaturaEmpleado_RHTblEmpleados_IDEmpleado]
GO
