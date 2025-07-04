USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEvaluadoresRequeridos](
	[IDEvaluadorRequerido] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[IDTipoRelacion] [int] NOT NULL,
	[Minimo] [int] NULL,
	[Maximo] [int] NULL,
 CONSTRAINT [Pk_Evaluacion360TblEvaluadoresRequeridos_IDEvaluadorRequerido] PRIMARY KEY CLUSTERED 
(
	[IDEvaluadorRequerido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEvaluadoresRequeridos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEvaluadoresRequeridos_Evaluacion360TblCatProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblEvaluadoresRequeridos] CHECK CONSTRAINT [Fk_Evaluacion360TblEvaluadoresRequeridos_Evaluacion360TblCatProyectos_IDProyecto]
GO
ALTER TABLE [Evaluacion360].[tblEvaluadoresRequeridos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEvaluadoresRequeridos_Evaluacion360TblCatTiposRelaciones_IDTipoRelacion] FOREIGN KEY([IDTipoRelacion])
REFERENCES [Evaluacion360].[tblCatTiposRelaciones] ([IDTipoRelacion])
GO
ALTER TABLE [Evaluacion360].[tblEvaluadoresRequeridos] CHECK CONSTRAINT [Fk_Evaluacion360TblEvaluadoresRequeridos_Evaluacion360TblCatTiposRelaciones_IDTipoRelacion]
GO
