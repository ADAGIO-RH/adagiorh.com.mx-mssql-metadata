USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Intranet].[tblSolicitudesEmpleado](
	[IDSolicitud] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoSolicitud] [int] NOT NULL,
	[IDEstatusSolicitud] [int] NOT NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIni] [date] NULL,
	[CantidadDias] [int] NULL,
	[FechaCreacion] [datetime] NULL,
	[ComentarioEmpleado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ComentarioSupervisor] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CantidadMonto] [decimal](18, 2) NULL,
	[IDUsuarioAutoriza] [int] NULL,
	[DiasDescanso] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaFin] [date] NULL,
	[DiasDisponibles] [int] NULL,
 CONSTRAINT [PK_IntranetTblSolicitudesEmpleado_IDSolicitud] PRIMARY KEY CLUSTERED 
(
	[IDSolicitud] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblCatIncidencias_IntranettblSolicitudesEmpleado_IDIncidencia] FOREIGN KEY([IDIncidencia])
REFERENCES [Asistencia].[tblCatIncidencias] ([IDIncidencia])
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado] CHECK CONSTRAINT [FK_AsistenciaTblCatIncidencias_IntranettblSolicitudesEmpleado_IDIncidencia]
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_IntranetTblCatEstatusSolicitudes_IntranetTblSolicitudesEmpleado_IDEstatusSolicitud] FOREIGN KEY([IDEstatusSolicitud])
REFERENCES [Intranet].[tblCatEstatusSolicitudes] ([IDEstatusSolicitud])
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado] CHECK CONSTRAINT [FK_IntranetTblCatEstatusSolicitudes_IntranetTblSolicitudesEmpleado_IDEstatusSolicitud]
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_IntranetTblCatTipoSolicitud_IntranetTblSolicitudesEmpleado_IDTipoSolicitud] FOREIGN KEY([IDTipoSolicitud])
REFERENCES [Intranet].[tblCatTipoSolicitud] ([IDTipoSolicitud])
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado] CHECK CONSTRAINT [FK_IntranetTblCatTipoSolicitud_IntranetTblSolicitudesEmpleado_IDTipoSolicitud]
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_IntranetTblSolicitudesEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_IntranetTblSolicitudesEmpleado_IDEmpleado]
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadtblUsuarios_IntranettblSolicitudesEmpleados_IDUsuario] FOREIGN KEY([IDUsuarioAutoriza])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Intranet].[tblSolicitudesEmpleado] CHECK CONSTRAINT [FK_SeguridadtblUsuarios_IntranettblSolicitudesEmpleados_IDUsuario]
GO
