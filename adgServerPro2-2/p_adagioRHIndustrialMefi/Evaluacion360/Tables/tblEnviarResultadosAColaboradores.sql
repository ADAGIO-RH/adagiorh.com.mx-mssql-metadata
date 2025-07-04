USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEnviarResultadosAColaboradores](
	[IDEnviarResultadosAColaboradores] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleadoProyecto] [int] NOT NULL,
	[Valor] [bit] NULL,
 CONSTRAINT [Pk_Evaluacion360TblEnviarResultadosAColaboradores_IDEnviarResultadosAColaboradores] PRIMARY KEY CLUSTERED 
(
	[IDEnviarResultadosAColaboradores] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEnviarResultadosAColaboradores] ADD  CONSTRAINT [D_Evaluacion360TblEnviarResultadosAColaboradores_Valor]  DEFAULT ((0)) FOR [Valor]
GO
ALTER TABLE [Evaluacion360].[tblEnviarResultadosAColaboradores]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEnviarResultadosAColaboradores__Evaluacion360TblProyectos_IDEmpleadoProyecto] FOREIGN KEY([IDEmpleadoProyecto])
REFERENCES [Evaluacion360].[tblEmpleadosProyectos] ([IDEmpleadoProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblEnviarResultadosAColaboradores] CHECK CONSTRAINT [Fk_Evaluacion360TblEnviarResultadosAColaboradores__Evaluacion360TblProyectos_IDEmpleadoProyecto]
GO
