USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEstatusEvaluacionEmpleado](
	[IDEstatusEvaluacionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEvaluacionEmpleado] [int] NOT NULL,
	[IDEstatus] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaCreacion] [datetime] NULL,
 CONSTRAINT [Pk_Evaluacion360TblEstatusEvaluacionEmpleado_IDEstatusEvaluacionEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDEstatusEvaluacionEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEstatusEvaluacionEmpleado] ADD  CONSTRAINT [D_Evaluacion360TblEstatusEvaluacionEmpleado_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Evaluacion360].[tblEstatusEvaluacionEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEstatusEvaluacionEmpleado_IDEstatus] FOREIGN KEY([IDEstatus])
REFERENCES [Evaluacion360].[tblCatEstatus] ([IDEstatus])
GO
ALTER TABLE [Evaluacion360].[tblEstatusEvaluacionEmpleado] CHECK CONSTRAINT [Fk_Evaluacion360TblEstatusEvaluacionEmpleado_IDEstatus]
GO
ALTER TABLE [Evaluacion360].[tblEstatusEvaluacionEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEstatusEvaluacionEmpleado_IDEvaluacionEmpleado] FOREIGN KEY([IDEvaluacionEmpleado])
REFERENCES [Evaluacion360].[tblEvaluacionesEmpleados] ([IDEvaluacionEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblEstatusEvaluacionEmpleado] CHECK CONSTRAINT [Fk_Evaluacion360TblEstatusEvaluacionEmpleado_IDEvaluacionEmpleado]
GO
ALTER TABLE [Evaluacion360].[tblEstatusEvaluacionEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEstatusEvaluacionEmpleado_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Evaluacion360].[tblEstatusEvaluacionEmpleado] CHECK CONSTRAINT [Fk_Evaluacion360TblEstatusEvaluacionEmpleado_IDUsuario]
GO
