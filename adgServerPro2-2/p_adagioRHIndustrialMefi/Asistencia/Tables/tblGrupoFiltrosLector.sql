USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblGrupoFiltrosLector](
	[IDGrupoFiltrosLector] [int] IDENTITY(1,1) NOT NULL,
	[IDLector] [int] NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuarioCreo] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_AsistenciatblGrupoFiltrosLector_IDGrupoFiltrosLector] PRIMARY KEY CLUSTERED 
(
	[IDGrupoFiltrosLector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblGrupoFiltrosLector] ADD  CONSTRAINT [D_AsistenciatblGrupoFiltrosLector_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Asistencia].[tblGrupoFiltrosLector]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblLectores_AsistenciatblGrupoFiltrosLector_IDLector] FOREIGN KEY([IDLector])
REFERENCES [Asistencia].[tblLectores] ([IDLector])
ON DELETE CASCADE
GO
ALTER TABLE [Asistencia].[tblGrupoFiltrosLector] CHECK CONSTRAINT [Fk_AsistenciaTblLectores_AsistenciatblGrupoFiltrosLector_IDLector]
GO
ALTER TABLE [Asistencia].[tblGrupoFiltrosLector]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblUsuarios_AsistenciatblGrupoFiltrosLector_IDUsuarioCreo] FOREIGN KEY([IDUsuarioCreo])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Asistencia].[tblGrupoFiltrosLector] CHECK CONSTRAINT [Fk_SeguridadTblUsuarios_AsistenciatblGrupoFiltrosLector_IDUsuarioCreo]
GO
