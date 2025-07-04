USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblIncidenciasSaldos](
	[IDIncidenciaSaldo] [int] IDENTITY(1,1) NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [Pk_AsistenciatblIncidenciasSaldos_IDIncidenciaSaldo] PRIMARY KEY CLUSTERED 
(
	[IDIncidenciaSaldo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblIncidenciasSaldos]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncidenciasSaldos_AsistenciatblCatIncidencias_IDIncidencia] FOREIGN KEY([IDIncidencia])
REFERENCES [Asistencia].[tblCatIncidencias] ([IDIncidencia])
GO
ALTER TABLE [Asistencia].[tblIncidenciasSaldos] CHECK CONSTRAINT [FK_AsistenciatblIncidenciasSaldos_AsistenciatblCatIncidencias_IDIncidencia]
GO
ALTER TABLE [Asistencia].[tblIncidenciasSaldos]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncidenciasSaldos_RHtblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Asistencia].[tblIncidenciasSaldos] CHECK CONSTRAINT [FK_AsistenciatblIncidenciasSaldos_RHtblEmpleados_IDEmpleado]
GO
ALTER TABLE [Asistencia].[tblIncidenciasSaldos]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblIncidenciasSaldos_Seguridadtblusuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Asistencia].[tblIncidenciasSaldos] CHECK CONSTRAINT [FK_AsistenciatblIncidenciasSaldos_Seguridadtblusuarios_IDUsuario]
GO
