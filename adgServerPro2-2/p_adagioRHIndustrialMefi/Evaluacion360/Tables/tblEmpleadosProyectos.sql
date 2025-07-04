USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEmpleadosProyectos](
	[IDEmpleadoProyecto] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[PDFGenerado] [bit] NOT NULL,
	[TotalGeneral] [decimal](10, 1) NOT NULL,
	[TotalCompetencias] [decimal](10, 1) NOT NULL,
	[TotalKPIs] [decimal](10, 1) NOT NULL,
	[TotalValores] [decimal](10, 1) NULL,
	[TipoFiltro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDNotificacion] [int] NULL,
 CONSTRAINT [PkEvaluacion360TblEmpleadosProyectos_IDEmpleadoProyecto] PRIMARY KEY CLUSTERED 
(
	[IDEmpleadoProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [R_Evaluacion360TblEmpleadosProyectos_IDProyectoIDEmpleado] UNIQUE NONCLUSTERED 
(
	[IDProyecto] ASC,
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEmpleadosProyectos] ADD  CONSTRAINT [D_Evaluacion360TblEmpleadosProyectos_PDFGenerado]  DEFAULT ((0)) FOR [PDFGenerado]
GO
ALTER TABLE [Evaluacion360].[tblEmpleadosProyectos] ADD  CONSTRAINT [D_Evaluacion360TblEmpleadosProyectos_TotalGeneral]  DEFAULT ((0.0)) FOR [TotalGeneral]
GO
ALTER TABLE [Evaluacion360].[tblEmpleadosProyectos] ADD  CONSTRAINT [D_Evaluacion360TblEmpleadosProyectos_TotalCompetencias]  DEFAULT ((0.0)) FOR [TotalCompetencias]
GO
ALTER TABLE [Evaluacion360].[tblEmpleadosProyectos] ADD  CONSTRAINT [D_Evaluacion360TblEmpleadosProyectos_TotalKPIs]  DEFAULT ((0.0)) FOR [TotalKPIs]
GO
ALTER TABLE [Evaluacion360].[tblEmpleadosProyectos] ADD  CONSTRAINT [D_Evaluacion360TblEmpleadosProyectos_TotalValores]  DEFAULT ((0.0)) FOR [TotalValores]
GO
ALTER TABLE [Evaluacion360].[tblEmpleadosProyectos]  WITH CHECK ADD  CONSTRAINT [Pk_Evaluacion360TblEmpleadosProyectos_Evaluacion360TblProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblEmpleadosProyectos] CHECK CONSTRAINT [Pk_Evaluacion360TblEmpleadosProyectos_Evaluacion360TblProyectos_IDProyecto]
GO
ALTER TABLE [Evaluacion360].[tblEmpleadosProyectos]  WITH CHECK ADD  CONSTRAINT [Pk_Evaluacion360TblEmpleadosProyectos_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblEmpleadosProyectos] CHECK CONSTRAINT [Pk_Evaluacion360TblEmpleadosProyectos_RHTblEmpleados_IDEmpleado]
GO
