USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblBitacoraChecadas](
	[IDBitacoraChecada] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NULL,
	[Fecha] [datetime] NOT NULL,
	[IDLector] [int] NULL,
	[Mensaje] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Latitud] [float] NULL,
	[Longitud] [float] NULL,
 CONSTRAINT [PK_AsistenciaTblBitacoraChecadas_IDBitacoraChecada] PRIMARY KEY CLUSTERED 
(
	[IDBitacoraChecada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblBitacoraChecadas_Fecha] ON [Asistencia].[tblBitacoraChecadas]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblBitacoraChecadas_IDEmpleado] ON [Asistencia].[tblBitacoraChecadas]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciaTblBitacoraChecadas_IDEmpleado_Fecha_IDLector_Mensaje] ON [Asistencia].[tblBitacoraChecadas]
(
	[IDEmpleado] ASC,
	[Fecha] ASC
)
INCLUDE([IDLector],[Mensaje]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblBitacoraChecadas_IDLector] ON [Asistencia].[tblBitacoraChecadas]
(
	[IDLector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblBitacoraChecadas]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblLectores_AsistenciatblBitacoraChecadas_IDLector] FOREIGN KEY([IDLector])
REFERENCES [Asistencia].[tblLectores] ([IDLector])
GO
ALTER TABLE [Asistencia].[tblBitacoraChecadas] CHECK CONSTRAINT [FK_AsistenciaTblLectores_AsistenciatblBitacoraChecadas_IDLector]
GO
