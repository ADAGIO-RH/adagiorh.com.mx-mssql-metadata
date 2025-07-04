USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblIncidenciaEmpleado](
	[IDIncidenciaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Fecha] [date] NOT NULL,
	[TiempoSugerido] [time](7) NULL,
	[TiempoAutorizado] [time](7) NULL,
	[Comentario] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CreadoPorIDUsuario] [int] NULL,
	[Autorizado] [bit] NOT NULL,
	[AutorizadoPor] [int] NULL,
	[FechaHoraAutorizacion] [datetime] NULL,
	[FechaHoraCreacion] [datetime] NULL,
	[IDIncapacidadEmpleado] [int] NULL,
	[ComentarioTextoPlano] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TiempoExtraDecimal]  AS ((datepart(hour,[TiempoAutorizado])+datepart(minute,[TiempoAutorizado])/(60.00))+datepart(second,[TiempoAutorizado])/(3600.00)),
	[HorarioAD] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDHorario] [int] NULL,
	[Entrada] [datetime] NULL,
	[Salida] [datetime] NULL,
	[TiempoTrabajado]  AS (CONVERT([varchar],[Salida]-[Entrada],(8))),
	[IDPapeleta] [int] NULL,
 CONSTRAINT [Pk_AsistenciatblIncidenciaEmpleado_IDIncidenciaEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDIncidenciaEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AsistenciaTblIncidenciaEmpleadoIDEmpleadoFechaIDIncidenciaHorarioAD] UNIQUE NONCLUSTERED 
(
	[IDEmpleado] ASC,
	[Fecha] ASC,
	[IDIncidencia] ASC,
	[HorarioAD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciaTblIncidenciaEmpleado_Autorizado_IDEmpleado_IDIncidencia_Fecha] ON [Asistencia].[tblIncidenciaEmpleado]
(
	[Autorizado] ASC
)
INCLUDE([IDEmpleado],[IDIncidencia],[Fecha]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblIncidenciaEmpleado_Fecha] ON [Asistencia].[tblIncidenciaEmpleado]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblIncidenciaEmpleado_IDEmpleado] ON [Asistencia].[tblIncidenciaEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblIncidenciaEmpleado_IDEmpleado_Fecha] ON [Asistencia].[tblIncidenciaEmpleado]
(
	[IDEmpleado] ASC,
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblIncidenciaEmpleado_IDEmpleado_Fecha_IDIncidencia] ON [Asistencia].[tblIncidenciaEmpleado]
(
	[IDEmpleado] ASC,
	[IDIncidencia] ASC,
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblIncidenciaEmpleado_IDIncidencia] ON [Asistencia].[tblIncidenciaEmpleado]
(
	[IDIncidencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado] ADD  CONSTRAINT [D_AsistenciatblIncidenciaEmpleado_Autorizado]  DEFAULT ((0)) FOR [Autorizado]
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado] ADD  CONSTRAINT [D_AsistenciatblIncidenciaEmpleado_FechaHoraCreacion]  DEFAULT (getdate()) FOR [FechaHoraCreacion]
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblIncidenciaEmpleado_AsistenciaTblCatHorarios_IDHorario] FOREIGN KEY([IDHorario])
REFERENCES [Asistencia].[tblCatHorarios] ([IDHorario])
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado] CHECK CONSTRAINT [Fk_AsistenciaTblIncidenciaEmpleado_AsistenciaTblCatHorarios_IDHorario]
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncidenciaEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado] CHECK CONSTRAINT [FK_AsistenciatblIncidenciaEmpleado_IDEmpleado]
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncidenciaEmpleado_IDIncapacidadEmpleado] FOREIGN KEY([IDIncapacidadEmpleado])
REFERENCES [Asistencia].[tblIncapacidadEmpleado] ([IDIncapacidadEmpleado])
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado] CHECK CONSTRAINT [FK_AsistenciatblIncidenciaEmpleado_IDIncapacidadEmpleado]
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncidenciaEmpleado_IDIncidencia] FOREIGN KEY([IDIncidencia])
REFERENCES [Asistencia].[tblCatIncidencias] ([IDIncidencia])
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado] CHECK CONSTRAINT [FK_AsistenciatblIncidenciaEmpleado_IDIncidencia]
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblPapeletas_AsistenciaTblIncidenciaEmpleado_IDPapeleta] FOREIGN KEY([IDPapeleta])
REFERENCES [Asistencia].[tblPapeletas] ([IDPapeleta])
GO
ALTER TABLE [Asistencia].[tblIncidenciaEmpleado] CHECK CONSTRAINT [FK_AsistenciaTblPapeletas_AsistenciaTblIncidenciaEmpleado_IDPapeleta]
GO
