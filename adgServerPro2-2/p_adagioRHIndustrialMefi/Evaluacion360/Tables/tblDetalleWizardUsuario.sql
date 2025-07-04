USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblDetalleWizardUsuario](
	[IDDetalleWizardUsuario] [int] IDENTITY(1,1) NOT NULL,
	[IDWizardUsuario] [int] NOT NULL,
	[IDWizardItem] [int] NOT NULL,
	[Completo] [bit] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblDetalleWizardUsuario_IDDetalleWizardUsuario] PRIMARY KEY CLUSTERED 
(
	[IDDetalleWizardUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblDetalleWizardUsuario] ADD  CONSTRAINT [D_Evaluacion360TblDetalleWizardUsuario_Completo]  DEFAULT ((0)) FOR [Completo]
GO
ALTER TABLE [Evaluacion360].[tblDetalleWizardUsuario] ADD  CONSTRAINT [D_Evaluacion360TblDetalleWizardUsuarioFechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Evaluacion360].[tblDetalleWizardUsuario]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblDetalleWizardUsuario_IDWizardItem] FOREIGN KEY([IDWizardItem])
REFERENCES [Evaluacion360].[tblCatWizardItem] ([IDWizardItem])
GO
ALTER TABLE [Evaluacion360].[tblDetalleWizardUsuario] CHECK CONSTRAINT [Fk_Evaluacion360TblDetalleWizardUsuario_IDWizardItem]
GO
ALTER TABLE [Evaluacion360].[tblDetalleWizardUsuario]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblDetalleWizardUsuarios_IDWizardUsuario] FOREIGN KEY([IDWizardUsuario])
REFERENCES [Evaluacion360].[tblWizardsUsuarios] ([IDWizardUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblDetalleWizardUsuario] CHECK CONSTRAINT [Fk_Evaluacion360TblDetalleWizardUsuarios_IDWizardUsuario]
GO
