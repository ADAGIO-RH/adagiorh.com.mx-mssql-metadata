USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblRecordarioEnviadosPorProyecto](
	[IDRecordatorioEviadosPorProyecto] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[IDTipoRecordatorio] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_Evaluacion360TblRecordarioEnviadosPorProyecto_IDRecordatorioEviadosPorProyecto] PRIMARY KEY CLUSTERED 
(
	[IDRecordatorioEviadosPorProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblRecordarioEnviadosPorProyecto] ADD  CONSTRAINT [D_Evaluacion360TblRecordarioEnviadosPorProyecto_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Evaluacion360].[tblRecordarioEnviadosPorProyecto]  WITH CHECK ADD  CONSTRAINT [Pk_Evaluacion360TblRecordarioEnviadosPorProyecto_Evaluacion360TblProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblRecordarioEnviadosPorProyecto] CHECK CONSTRAINT [Pk_Evaluacion360TblRecordarioEnviadosPorProyecto_Evaluacion360TblProyectos_IDProyecto]
GO
