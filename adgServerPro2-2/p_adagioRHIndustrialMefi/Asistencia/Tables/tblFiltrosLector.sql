USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblFiltrosLector](
	[IDFiltroLector] [int] IDENTITY(1,1) NOT NULL,
	[IDLector] [int] NOT NULL,
	[IDGrupoFiltrosLector] [int] NOT NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_AsistenciatblFiltrosLector_IDFiltroLector] PRIMARY KEY CLUSTERED 
(
	[IDFiltroLector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblFiltrosLector]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciatblGrupoFiltrosLector_AsistenciatblFiltrosLector_IDGrupoFiltrosLector] FOREIGN KEY([IDGrupoFiltrosLector])
REFERENCES [Asistencia].[tblGrupoFiltrosLector] ([IDGrupoFiltrosLector])
ON DELETE CASCADE
GO
ALTER TABLE [Asistencia].[tblFiltrosLector] CHECK CONSTRAINT [Fk_AsistenciatblGrupoFiltrosLector_AsistenciatblFiltrosLector_IDGrupoFiltrosLector]
GO
ALTER TABLE [Asistencia].[tblFiltrosLector]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblLectores_AsistenciatblFiltrosLector_IDLector] FOREIGN KEY([IDLector])
REFERENCES [Asistencia].[tblLectores] ([IDLector])
GO
ALTER TABLE [Asistencia].[tblFiltrosLector] CHECK CONSTRAINT [FK_AsistenciaTblLectores_AsistenciatblFiltrosLector_IDLector]
GO
ALTER TABLE [Asistencia].[tblFiltrosLector]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadtblCatTiposFiltros_AsistenciatblFiltrosLector_Filtro] FOREIGN KEY([Filtro])
REFERENCES [Seguridad].[tblCatTiposFiltros] ([Filtro])
GO
ALTER TABLE [Asistencia].[tblFiltrosLector] CHECK CONSTRAINT [FK_SeguridadtblCatTiposFiltros_AsistenciatblFiltrosLector_Filtro]
GO
