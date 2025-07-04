USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblPlanDeAccion](
	[IDPlanDeAccion] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleadoProyecto] [int] NOT NULL,
	[IDTipoGrupo] [int] NOT NULL,
	[Grupo] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CalificacionActual] [decimal](18, 2) NULL,
	[Acciones] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ResultadoEsperado] [decimal](18, 2) NULL,
	[FechaCompromiso] [date] NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_Evaluacion360TblPlanDeAccion_IDPlanDeAccion] PRIMARY KEY CLUSTERED 
(
	[IDPlanDeAccion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblPlanDeAccion] ADD  CONSTRAINT [D_Evaluacion360TblPlanDeAccion_CalificacionActual]  DEFAULT ((0)) FOR [CalificacionActual]
GO
ALTER TABLE [Evaluacion360].[tblPlanDeAccion] ADD  CONSTRAINT [D_Evaluacion360TblPlanDeAccion_ResultadoEsperado]  DEFAULT ((0)) FOR [ResultadoEsperado]
GO
ALTER TABLE [Evaluacion360].[tblPlanDeAccion] ADD  CONSTRAINT [D_Evaluacion360TblPlanDeAccion_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Evaluacion360].[tblPlanDeAccion]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblPlanDeAccion_Evaluacion360TblCatTipoGrupo_IDTipoGrupo] FOREIGN KEY([IDTipoGrupo])
REFERENCES [Evaluacion360].[tblCatTipoGrupo] ([IDTipoGrupo])
GO
ALTER TABLE [Evaluacion360].[tblPlanDeAccion] CHECK CONSTRAINT [Fk_Evaluacion360TblPlanDeAccion_Evaluacion360TblCatTipoGrupo_IDTipoGrupo]
GO
ALTER TABLE [Evaluacion360].[tblPlanDeAccion]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblPlanDeAccion_Evaluacion360TblEmpleadosProyectos_IDEmpleadoProyecto] FOREIGN KEY([IDEmpleadoProyecto])
REFERENCES [Evaluacion360].[tblEmpleadosProyectos] ([IDEmpleadoProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblPlanDeAccion] CHECK CONSTRAINT [Fk_Evaluacion360TblPlanDeAccion_Evaluacion360TblEmpleadosProyectos_IDEmpleadoProyecto]
GO
ALTER TABLE [Evaluacion360].[tblPlanDeAccion]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblPlanDeAccion_SeguridadTblUsuarios] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Evaluacion360].[tblPlanDeAccion] CHECK CONSTRAINT [Fk_Evaluacion360TblPlanDeAccion_SeguridadTblUsuarios]
GO
