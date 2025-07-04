USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblIncapacidadEmpleado](
	[IDIncapacidadEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Numero] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Fecha] [date] NOT NULL,
	[Duracion] [int] NOT NULL,
	[IDTipoIncapacidad] [int] NOT NULL,
	[IDClasificacionIncapacidad] [int] NULL,
	[PagoSubsidioEmpresa] [bit] NULL,
	[IDCausaAccidente] [int] NULL,
	[IDCorreccionAccidente] [int] NULL,
	[IDTipoLesion] [int] NULL,
	[Hora] [time](7) NULL,
	[Dia] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoRiesgoIncapacidad] [int] NULL,
	[Permanente] [bit] NULL,
 CONSTRAINT [Pk_AsistenciatblIncapacidadEmpleado_IDIncapacidadEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDIncapacidadEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Numero] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblIncapacidadEmpleado_Fecha] ON [Asistencia].[tblIncapacidadEmpleado]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblIncapacidadEmpleado_IDEmpleado] ON [Asistencia].[tblIncapacidadEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblIncapacidadEmpleado_IDTipoIncapacidad] ON [Asistencia].[tblIncapacidadEmpleado]
(
	[IDTipoIncapacidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado] ADD  CONSTRAINT [D_AsistenciatblIncapacidadEmpleado_PagoSubsidioEmpresa]  DEFAULT ((0)) FOR [PagoSubsidioEmpresa]
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado] ADD  CONSTRAINT [D_AsistenciatblIncapacidadEmpleado_Permanente]  DEFAULT ((0)) FOR [Permanente]
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblCatClasificacionesIncapacidad_IDTipoLesion] FOREIGN KEY([IDTipoLesion])
REFERENCES [IMSS].[tblCatTiposLesiones] ([IDTipoLesion])
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado] CHECK CONSTRAINT [FK_AsistenciatblCatClasificacionesIncapacidad_IDTipoLesion]
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblCatClasificacionesIncapacidad_IDTipoRiesgoIncapacidad] FOREIGN KEY([IDTipoRiesgoIncapacidad])
REFERENCES [IMSS].[tblCatTipoRiesgoIncapacidad] ([IDTipoRiesgoIncapacidad])
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado] CHECK CONSTRAINT [FK_AsistenciatblCatClasificacionesIncapacidad_IDTipoRiesgoIncapacidad]
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDCausaAccidente] FOREIGN KEY([IDCausaAccidente])
REFERENCES [IMSS].[tblCatCausasAccidentes] ([IDCausaAccidente])
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado] CHECK CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDCausaAccidente]
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDClasificacionIncapacidad] FOREIGN KEY([IDClasificacionIncapacidad])
REFERENCES [IMSS].[tblCatClasificacionesIncapacidad] ([IDClasificacionIncapacidad])
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado] CHECK CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDClasificacionIncapacidad]
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDCorreccionAccidente] FOREIGN KEY([IDCorreccionAccidente])
REFERENCES [IMSS].[tblCatCorreccionesAccidentes] ([IDCorreccionAccidente])
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado] CHECK CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDCorreccionAccidente]
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado] CHECK CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDEmpleado]
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDTipoIncapacidad] FOREIGN KEY([IDTipoIncapacidad])
REFERENCES [Sat].[tblCatTiposIncapacidad] ([IDTIpoIncapacidad])
GO
ALTER TABLE [Asistencia].[tblIncapacidadEmpleado] CHECK CONSTRAINT [FK_AsistenciatblIncapacidadEmpleado_IDTipoIncapacidad]
GO
