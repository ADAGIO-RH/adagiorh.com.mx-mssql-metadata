USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblWizardsUsuarios](
	[IDWizardUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Completo] [bit] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblWizardsUsuarios_IDWizardUsuario] PRIMARY KEY CLUSTERED 
(
	[IDWizardUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblWizardsUsuarios] ADD  CONSTRAINT [D_Evaluacion360TblWizardsUsuarios_Completo]  DEFAULT ((0)) FOR [Completo]
GO
ALTER TABLE [Evaluacion360].[tblWizardsUsuarios] ADD  CONSTRAINT [D_Evaluacion360TblWizardsUsuariosFechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Evaluacion360].[tblWizardsUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblWizardsUsuarios_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblWizardsUsuarios] CHECK CONSTRAINT [Fk_Evaluacion360TblWizardsUsuarios_IDProyecto]
GO
ALTER TABLE [Evaluacion360].[tblWizardsUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblWizardsUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblWizardsUsuarios] CHECK CONSTRAINT [Fk_Evaluacion360TblWizardsUsuarios_IDUsuario]
GO
