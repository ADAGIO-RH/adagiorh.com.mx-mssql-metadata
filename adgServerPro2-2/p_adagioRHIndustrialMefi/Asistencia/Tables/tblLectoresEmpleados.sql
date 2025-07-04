USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblLectoresEmpleados](
	[IDLectorEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDLector] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Fecha] [datetime] NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorFiltro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDGrupoFiltrosLector] [int] NULL,
 CONSTRAINT [PK_AsistenciaTbllectoresEmpleados_IdLectorEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDLectorEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblLectoresEmpleados_IDEmpleado] ON [Asistencia].[tblLectoresEmpleados]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblLectoresEmpleados_IDLector] ON [Asistencia].[tblLectoresEmpleados]
(
	[IDLector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblLectoresEmpleados_IDLector_IDEmpleado] ON [Asistencia].[tblLectoresEmpleados]
(
	[IDLector] ASC,
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblLectoresEmpleados] ADD  DEFAULT (getdate()) FOR [Fecha]
GO
ALTER TABLE [Asistencia].[tblLectoresEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblLectores_AsistenciaTbllectoresEmpleados_IDLector] FOREIGN KEY([IDLector])
REFERENCES [Asistencia].[tblLectores] ([IDLector])
GO
ALTER TABLE [Asistencia].[tblLectoresEmpleados] CHECK CONSTRAINT [FK_AsistenciaTblLectores_AsistenciaTbllectoresEmpleados_IDLector]
GO
ALTER TABLE [Asistencia].[tblLectoresEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_AsistenciaTblLectoresEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblLectoresEmpleados] CHECK CONSTRAINT [FK_RHtblEmpleados_AsistenciaTblLectoresEmpleados_IDEmpleado]
GO
ALTER TABLE [Asistencia].[tblLectoresEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatTiposFiltros_AsistenciaTblLectoresEmpleados_Filtro] FOREIGN KEY([Filtro])
REFERENCES [Seguridad].[tblCatTiposFiltros] ([Filtro])
GO
ALTER TABLE [Asistencia].[tblLectoresEmpleados] CHECK CONSTRAINT [FK_SeguridadTblCatTiposFiltros_AsistenciaTblLectoresEmpleados_Filtro]
GO
