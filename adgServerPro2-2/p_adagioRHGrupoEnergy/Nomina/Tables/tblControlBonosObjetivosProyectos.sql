USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlBonosObjetivosProyectos](
	[IDControlBonosObjetivosProyecto] [int] IDENTITY(1,1) NOT NULL,
	[IDControlBonosObjetivos] [int] NOT NULL,
	[IDProyecto] [int] NOT NULL,
 CONSTRAINT [PK_NominatblControlBonosObjetivosProyectos_IDControlBonosObjetivosProyecto] PRIMARY KEY CLUSTERED 
(
	[IDControlBonosObjetivosProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosProyectos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivosProyecto_Evaluacion360tblCatProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosProyectos] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivosProyecto_Evaluacion360tblCatProyectos_IDProyecto]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosProyectos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivosProyecto_NominatblControlBonosObjetivos_IDControlBonosObjetivos] FOREIGN KEY([IDControlBonosObjetivos])
REFERENCES [Nomina].[tblControlBonosObjetivos] ([IDControlBonosObjetivos])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosProyectos] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivosProyecto_NominatblControlBonosObjetivos_IDControlBonosObjetivos]
GO
