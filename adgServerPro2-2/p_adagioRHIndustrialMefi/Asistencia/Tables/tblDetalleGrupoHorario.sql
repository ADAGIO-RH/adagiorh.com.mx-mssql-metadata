USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblDetalleGrupoHorario](
	[IDDetalleGrupoHorario] [int] IDENTITY(1,1) NOT NULL,
	[IDGrupoHorario] [int] NULL,
	[IDHorario] [int] NOT NULL,
 CONSTRAINT [Pk_AsistenciaTblDetalleGrupoHorario_IDDetalleGrupoHorario] PRIMARY KEY CLUSTERED 
(
	[IDDetalleGrupoHorario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AsistenciatblDetalleGrupoHorario_IDGrupoHorarioIDHorario] UNIQUE NONCLUSTERED 
(
	[IDGrupoHorario] ASC,
	[IDHorario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblDetalleGrupoHorario]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciatblDetalleGrupoHorario_IDHorario] FOREIGN KEY([IDHorario])
REFERENCES [Asistencia].[tblCatHorarios] ([IDHorario])
ON DELETE CASCADE
GO
ALTER TABLE [Asistencia].[tblDetalleGrupoHorario] CHECK CONSTRAINT [Fk_AsistenciatblDetalleGrupoHorario_IDHorario]
GO
ALTER TABLE [Asistencia].[tblDetalleGrupoHorario]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciatblDetalleGrupoHorario_IDHorarioGrupoHorario] FOREIGN KEY([IDGrupoHorario])
REFERENCES [Asistencia].[tblCatGruposHorarios] ([IDGrupoHorario])
ON DELETE CASCADE
GO
ALTER TABLE [Asistencia].[tblDetalleGrupoHorario] CHECK CONSTRAINT [Fk_AsistenciatblDetalleGrupoHorario_IDHorarioGrupoHorario]
GO
