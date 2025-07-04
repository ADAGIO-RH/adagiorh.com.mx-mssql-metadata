USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblHorariosEmpleados](
	[IDHorarioEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDHorario] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[FechaHoraRegistro] [datetime] NULL,
 CONSTRAINT [Pk_AsistenciaTblHorarioEmpleado_IDHorarioEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDHorarioEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AsistenciaTblHorariosEmpleadosIDEmpleadoFecha] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblHorariosEmpleados_Fecha] ON [Asistencia].[tblHorariosEmpleados]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblHorariosEmpleados_IDEmpleado] ON [Asistencia].[tblHorariosEmpleados]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblHorariosEmpleados_IDEmpleado_Fecha] ON [Asistencia].[tblHorariosEmpleados]
(
	[IDEmpleado] ASC,
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblHorariosEmpleados_IDHorario] ON [Asistencia].[tblHorariosEmpleados]
(
	[IDHorario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_AsistenciaTblHorariosEmpleados_Fecha] ON [Asistencia].[tblHorariosEmpleados]
(
	[Fecha] ASC
)
INCLUDE([IDEmpleado],[IDHorario],[FechaHoraRegistro]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblHorariosEmpleados] ADD  CONSTRAINT [D_AsistenciatblHorariosEmpleados_FechaHoraRegistro]  DEFAULT (getdate()) FOR [FechaHoraRegistro]
GO
ALTER TABLE [Asistencia].[tblHorariosEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblHorariosEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblHorariosEmpleados] CHECK CONSTRAINT [FK_AsistenciatblHorariosEmpleados_IDEmpleado]
GO
ALTER TABLE [Asistencia].[tblHorariosEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciatblHorariosEmpleados_IDHorario] FOREIGN KEY([IDHorario])
REFERENCES [Asistencia].[tblCatHorarios] ([IDHorario])
GO
ALTER TABLE [Asistencia].[tblHorariosEmpleados] CHECK CONSTRAINT [Fk_AsistenciatblHorariosEmpleados_IDHorario]
GO
