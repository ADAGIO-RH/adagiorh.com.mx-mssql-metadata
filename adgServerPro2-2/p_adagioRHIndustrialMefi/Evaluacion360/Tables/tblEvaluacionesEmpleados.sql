USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEvaluacionesEmpleados](
	[IDEvaluacionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleadoProyecto] [int] NULL,
	[IDTipoRelacion] [int] NULL,
	[IDEvaluador] [int] NULL,
	[TotalPreguntas] [int] NULL,
	[TotalPreguntasRespondidas] [int] NULL,
	[Progreso] [int] NULL,
	[IDTipoEvaluacion] [int] NULL,
	[Promedio] [decimal](10, 2) NULL,
	[Porcentaje] [decimal](10, 2) NULL,
 CONSTRAINT [Pk_Evaluacion360TblEvaluacionesEmpleados_IDEvaluacionEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDEvaluacionEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_Evaluacion360TblEvaluacionesEmpleados_IDEmpleadoProyectoIDEvaluador] ON [Evaluacion360].[tblEvaluacionesEmpleados]
(
	[IDEmpleadoProyecto] ASC,
	[IDEvaluador] ASC,
	[IDTipoEvaluacion] ASC,
	[IDTipoRelacion] ASC
)
WHERE ([IDEvaluador] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados] ADD  CONSTRAINT [D_Evaluacion360TblEvaluacionesEmpleados_TotalPreguntas]  DEFAULT ((0)) FOR [TotalPreguntas]
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados] ADD  CONSTRAINT [D_Evaluacion360TblEvaluacionesEmpleados_TotalPreguntasRespondidas]  DEFAULT ((0)) FOR [TotalPreguntasRespondidas]
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados] ADD  CONSTRAINT [D_Evaluacion360TblEvaluacionesEmpleados_Progreso]  DEFAULT ((0)) FOR [Progreso]
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEvaluacionesEmpleados_Evaluacion360TblCatTiposEvaluaciones_IDTipoEvaluacion] FOREIGN KEY([IDTipoEvaluacion])
REFERENCES [Evaluacion360].[tblCatTiposEvaluaciones] ([IDTipoEvaluacion])
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados] CHECK CONSTRAINT [Fk_Evaluacion360TblEvaluacionesEmpleados_Evaluacion360TblCatTiposEvaluaciones_IDTipoEvaluacion]
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEvaluacionesEmpleados_RHTblEmpleadosProyectos_IDEmpleadoProyecto] FOREIGN KEY([IDEmpleadoProyecto])
REFERENCES [Evaluacion360].[tblEmpleadosProyectos] ([IDEmpleadoProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados] CHECK CONSTRAINT [Fk_Evaluacion360TblEvaluacionesEmpleados_RHTblEmpleadosProyectos_IDEmpleadoProyecto]
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TtblEvaluacionesEmpleados_Evaluacion360TblCatTiposRelaciones_IDTipoRelacion] FOREIGN KEY([IDTipoRelacion])
REFERENCES [Evaluacion360].[tblCatTiposRelaciones] ([IDTipoRelacion])
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados] CHECK CONSTRAINT [Fk_Evaluacion360TtblEvaluacionesEmpleados_Evaluacion360TblCatTiposRelaciones_IDTipoRelacion]
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados]  WITH CHECK ADD  CONSTRAINT [Pk_Evaluacion360TblEvaluacionesEmpleados_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEvaluador])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Evaluacion360].[tblEvaluacionesEmpleados] CHECK CONSTRAINT [Pk_Evaluacion360TblEvaluacionesEmpleados_RHTblEmpleados_IDEmpleado]
GO
