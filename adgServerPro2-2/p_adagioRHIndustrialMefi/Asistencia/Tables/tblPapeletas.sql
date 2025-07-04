USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblPapeletas](
	[IDPapeleta] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaFin] [date] NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[TiempoAutorizado] [time](7) NULL,
	[TiempoSugerido] [time](7) NULL,
	[Dias] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Duracion] [int] NULL,
	[IDClasificacionIncapacidad] [int] NULL,
	[IDTipoIncapacidad] [int] NULL,
	[IDTipoLesion] [int] NULL,
	[IDTipoRiesgoIncapacidad] [int] NULL,
	[Numero] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PagoSubsidioEmpresa] [bit] NULL,
	[Permanente] [bit] NULL,
	[DiasDescanso] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fecha] [date] NULL,
	[Comentario] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ComentarioTextoPlano] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Autorizado] [bit] NULL,
	[FechaHora] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
	[PapeletaAutorizada] [bit] NULL,
	[IDIncidenciaEmpleado] [int] NULL,
 CONSTRAINT [Pk_AsistenciaTblPapeletas_IDPapeleta] PRIMARY KEY CLUSTERED 
(
	[IDPapeleta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblPapeletas] ADD  CONSTRAINT [D_AsistenciaTblPapeletas_Duracion]  DEFAULT ((0)) FOR [Duracion]
GO
ALTER TABLE [Asistencia].[tblPapeletas] ADD  CONSTRAINT [D_AsistenciaTblPapeletas_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Asistencia].[tblPapeletas] ADD  CONSTRAINT [D_AsistenciaTblPapeletas_PapeletaAutorizada]  DEFAULT ((0)) FOR [PapeletaAutorizada]
GO
ALTER TABLE [Asistencia].[tblPapeletas]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblPapeletas_AsistenciaTblCatIncidencias_IDIncidencia] FOREIGN KEY([IDIncidencia])
REFERENCES [Asistencia].[tblCatIncidencias] ([IDIncidencia])
GO
ALTER TABLE [Asistencia].[tblPapeletas] CHECK CONSTRAINT [Fk_AsistenciaTblPapeletas_AsistenciaTblCatIncidencias_IDIncidencia]
GO
ALTER TABLE [Asistencia].[tblPapeletas]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblPapeletas_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Asistencia].[tblPapeletas] CHECK CONSTRAINT [Fk_AsistenciaTblPapeletas_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [Asistencia].[tblPapeletas]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblPapeletas_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Asistencia].[tblPapeletas] CHECK CONSTRAINT [Fk_AsistenciaTblPapeletas_SeguridadTblUsuarios_IDUsuario]
GO
