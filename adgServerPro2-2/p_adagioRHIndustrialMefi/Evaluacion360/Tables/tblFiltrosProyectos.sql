USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblFiltrosProyectos](
	[IDFiltroProyecto] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[TipoFiltro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblFiltrosProyectos_IDFiltroProyecto] PRIMARY KEY CLUSTERED 
(
	[IDFiltroProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_Evaluacion360TblFiltrosProyectos_IDProyectoTipoFiltroID] UNIQUE NONCLUSTERED 
(
	[IDProyecto] ASC,
	[TipoFiltro] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblFiltrosProyectos]  WITH CHECK ADD  CONSTRAINT [Pk_Evaluacion360TblFiltrosProyectos_Evaluacion360TblProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblFiltrosProyectos] CHECK CONSTRAINT [Pk_Evaluacion360TblFiltrosProyectos_Evaluacion360TblProyectos_IDProyecto]
GO
