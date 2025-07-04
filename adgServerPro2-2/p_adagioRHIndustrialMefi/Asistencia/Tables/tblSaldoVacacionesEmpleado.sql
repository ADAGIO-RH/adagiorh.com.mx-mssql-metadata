USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblSaldoVacacionesEmpleado](
	[IDSaldoVacacionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Anio] [int] NOT NULL,
	[IDMovAfiliatorio] [int] NOT NULL,
	[IDTipoPrestacion] [int] NOT NULL,
	[DiasVigencia] [int] NULL,
	[FechaGeneracion]  AS (getdate()),
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[FechaInicioDisponible] [date] NOT NULL,
	[FechaFinDisponible] [date] NOT NULL,
	[IDAjusteSaldo] [int] NULL,
	[IDIncidenciaEmpleado] [int] NULL,
	[IDFiniquito] [int] NULL,
 CONSTRAINT [Pk_AsistenciaTblSaldosVacacionesEmpleados_IDSaldoVacacionEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDSaldoVacacionEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciaTblSaldoVacacionesEmpleado_WithInclude] ON [Asistencia].[tblSaldoVacacionesEmpleado]
(
	[IDEmpleado] ASC,
	[IDMovAfiliatorio] ASC,
	[IDAjusteSaldo] ASC,
	[IDIncidenciaEmpleado] ASC
)
INCLUDE([FechaInicioDisponible],[FechaFinDisponible]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciaTblSaldoVacacionesEmpleado_WithIncludeOnAnio] ON [Asistencia].[tblSaldoVacacionesEmpleado]
(
	[IDEmpleado] ASC,
	[IDMovAfiliatorio] ASC,
	[FechaInicioDisponible] ASC
)
INCLUDE([Anio],[IDTipoPrestacion],[FechaInicio],[FechaFin],[FechaFinDisponible],[IDAjusteSaldo],[IDIncidenciaEmpleado],[IDFiniquito]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_AsistenciatblSaldoVacacionesEmpleado_IDincidenciaEmpleado] ON [Asistencia].[tblSaldoVacacionesEmpleado]
(
	[IDIncidenciaEmpleado] ASC
)
WHERE ([IDincidenciaEmpleado] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_AsistenciatblAjustesSaldoVacacionesEmpleado_IDAjusteSaldo] FOREIGN KEY([IDAjusteSaldo])
REFERENCES [Asistencia].[tblAjustesSaldoVacacionesEmpleado] ([IDAjusteSaldo])
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado] CHECK CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_AsistenciatblAjustesSaldoVacacionesEmpleado_IDAjusteSaldo]
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_AsistenciaTblIncidenciaEmpleado_IDIncidenciaEmpleado] FOREIGN KEY([IDIncidenciaEmpleado])
REFERENCES [Asistencia].[tblIncidenciaEmpleado] ([IDIncidenciaEmpleado])
ON DELETE SET NULL
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado] CHECK CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_AsistenciaTblIncidenciaEmpleado_IDIncidenciaEmpleado]
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_ImssTblMovAfiliatorios_IDMovAfiliatorio] FOREIGN KEY([IDMovAfiliatorio])
REFERENCES [IMSS].[tblMovAfiliatorios] ([IDMovAfiliatorio])
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado] CHECK CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_ImssTblMovAfiliatorios_IDMovAfiliatorio]
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_NominaTblControlFiniquitos_IDFiniquito] FOREIGN KEY([IDFiniquito])
REFERENCES [Nomina].[tblControlFiniquitos] ([IDFiniquito])
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado] CHECK CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_NominaTblControlFiniquitos_IDFiniquito]
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_RhTblCatTiposPrestaciones_IDTipoPrestacion] FOREIGN KEY([IDTipoPrestacion])
REFERENCES [RH].[tblCatTiposPrestaciones] ([IDTipoPrestacion])
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado] CHECK CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_RhTblCatTiposPrestaciones_IDTipoPrestacion]
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_RhTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblSaldoVacacionesEmpleado] CHECK CONSTRAINT [Fk_AsistenciaTblSaldoVacacionesEmpleado_RhTblEmpleados_IDEmpleado]
GO
