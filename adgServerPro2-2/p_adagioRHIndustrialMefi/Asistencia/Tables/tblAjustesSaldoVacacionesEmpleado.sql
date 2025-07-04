USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblAjustesSaldoVacacionesEmpleado](
	[IDAjusteSaldo] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[SaldoFinal] [int] NULL,
	[FechaAjuste] [date] NULL,
	[IDMovAfiliatorio] [int] NULL,
 CONSTRAINT [Pk_AsistenciaTblAjustesSaldoVacacionesEmpleado_IDAjusteSaldo] PRIMARY KEY CLUSTERED 
(
	[IDAjusteSaldo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblAjustesSaldoVacacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblAjustesSaldoVacacionesEmpleado_ImssTblMovAfiliatorios_IDMovAfiliatorio] FOREIGN KEY([IDMovAfiliatorio])
REFERENCES [IMSS].[tblMovAfiliatorios] ([IDMovAfiliatorio])
GO
ALTER TABLE [Asistencia].[tblAjustesSaldoVacacionesEmpleado] CHECK CONSTRAINT [Fk_AsistenciaTblAjustesSaldoVacacionesEmpleado_ImssTblMovAfiliatorios_IDMovAfiliatorio]
GO
ALTER TABLE [Asistencia].[tblAjustesSaldoVacacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblAjustesSaldoVacacionesEmpleado_RhTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblAjustesSaldoVacacionesEmpleado] CHECK CONSTRAINT [Fk_AsistenciaTblAjustesSaldoVacacionesEmpleado_RhTblEmpleados_IDEmpleado]
GO
