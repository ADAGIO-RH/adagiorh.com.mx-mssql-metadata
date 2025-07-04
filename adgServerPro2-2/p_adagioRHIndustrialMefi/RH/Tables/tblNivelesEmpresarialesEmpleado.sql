USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblNivelesEmpresarialesEmpleado](
	[IDNivelEmpresarialEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDNivelEmpresarial] [int] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
 CONSTRAINT [Pk_RHtblNivelesEmpresarialesEmpleado_IDNivelEmpresarialEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDNivelEmpresarialEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblNivelesEmpresarialesEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblNivelesEmpresarialesEmpleado_RHtblCatNivelesEmpresariales_IDEmpleado] FOREIGN KEY([IDNivelEmpresarial])
REFERENCES [RH].[tblCatNivelesEmpresariales] ([IDNivelEmpresarial])
GO
ALTER TABLE [RH].[tblNivelesEmpresarialesEmpleado] CHECK CONSTRAINT [FK_RHtblNivelesEmpresarialesEmpleado_RHtblCatNivelesEmpresariales_IDEmpleado]
GO
ALTER TABLE [RH].[tblNivelesEmpresarialesEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblNivelesEmpresarialesEmpleado_RHtblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblNivelesEmpresarialesEmpleado] CHECK CONSTRAINT [FK_RHtblNivelesEmpresarialesEmpleado_RHtblEmpleados_IDEmpleado]
GO
