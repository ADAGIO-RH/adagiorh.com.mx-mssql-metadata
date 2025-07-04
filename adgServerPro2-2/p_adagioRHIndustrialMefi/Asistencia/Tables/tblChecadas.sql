USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblChecadas](
	[IDChecada] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[FechaOrigen] [date] NULL,
	[IDLector] [int] NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoChecada] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NULL,
	[Comentario] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDZonaHoraria] [int] NULL,
	[Automatica] [bit] NULL,
	[FechaReg] [datetime] NOT NULL,
	[FechaOriginal] [datetime] NULL,
	[Latitud] [float] NULL,
	[Longitud] [float] NULL,
 CONSTRAINT [PK_AsistenciatblChecadas_IDChecada] PRIMARY KEY CLUSTERED 
(
	[IDChecada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblChecadas_Fecha] ON [Asistencia].[tblChecadas]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblChecadas_FechaOrigen] ON [Asistencia].[tblChecadas]
(
	[FechaOrigen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblChecadas_FechaOrigen_IDEmpleado] ON [Asistencia].[tblChecadas]
(
	[FechaOrigen] ASC,
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblChecadas_IDEmpleado] ON [Asistencia].[tblChecadas]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblChecadas_IDLector] ON [Asistencia].[tblChecadas]
(
	[IDLector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblChecadas_IDTipoChecada] ON [Asistencia].[tblChecadas]
(
	[IDTipoChecada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciaTblChecadas_IDTipoChecada_IDChecadaFechaOrigenIDEmpleado] ON [Asistencia].[tblChecadas]
(
	[IDTipoChecada] ASC
)
INCLUDE([IDChecada],[FechaOrigen],[IDEmpleado]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_AsistenciaTblChecadas_FechaOrigen] ON [Asistencia].[tblChecadas]
(
	[FechaOrigen] ASC
)
INCLUDE([IDLector]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblChecadas] ADD  DEFAULT ((1)) FOR [Automatica]
GO
ALTER TABLE [Asistencia].[tblChecadas] ADD  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [Asistencia].[tblChecadas]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblCatTiposChecadas_AsistenciaTblChecadas_IDTipoChecada] FOREIGN KEY([IDTipoChecada])
REFERENCES [Asistencia].[tblCatTiposChecadas] ([IDTipoChecada])
GO
ALTER TABLE [Asistencia].[tblChecadas] CHECK CONSTRAINT [FK_AsistenciaTblCatTiposChecadas_AsistenciaTblChecadas_IDTipoChecada]
GO
ALTER TABLE [Asistencia].[tblChecadas]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblLectores_AsistenciaTblChecadas_IDLector] FOREIGN KEY([IDLector])
REFERENCES [Asistencia].[tblLectores] ([IDLector])
GO
ALTER TABLE [Asistencia].[tblChecadas] CHECK CONSTRAINT [FK_AsistenciaTblLectores_AsistenciaTblChecadas_IDLector]
GO
ALTER TABLE [Asistencia].[tblChecadas]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_AsistenciaTblChecadas_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblChecadas] CHECK CONSTRAINT [FK_RHTblEmpleados_AsistenciaTblChecadas_IDEmpleado]
GO
ALTER TABLE [Asistencia].[tblChecadas]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_AsistenciaTblChecadas_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Asistencia].[tblChecadas] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_AsistenciaTblChecadas_IDUsuario]
GO
ALTER TABLE [Asistencia].[tblChecadas]  WITH CHECK ADD  CONSTRAINT [FK_TzdbZones_AsistenciatblChecadas_IDZonaHoraria] FOREIGN KEY([IDZonaHoraria])
REFERENCES [Tzdb].[Zones] ([Id])
GO
ALTER TABLE [Asistencia].[tblChecadas] CHECK CONSTRAINT [FK_TzdbZones_AsistenciatblChecadas_IDZonaHoraria]
GO
