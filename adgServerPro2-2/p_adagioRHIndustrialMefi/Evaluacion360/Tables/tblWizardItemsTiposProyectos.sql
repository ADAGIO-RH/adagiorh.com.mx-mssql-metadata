USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblWizardItemsTiposProyectos](
	[IDTipoProyecto] [int] NOT NULL,
	[IDWizardItem] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblWizardItemsTiposProyectos_IDTipoProyectoIDWizardItem] PRIMARY KEY CLUSTERED 
(
	[IDTipoProyecto] ASC,
	[IDWizardItem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblWizardItemsTiposProyectos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblWizardItemsTiposProyectos_Evaluacion360TblCatTiposProyectos_IDTipoProyecto] FOREIGN KEY([IDTipoProyecto])
REFERENCES [Evaluacion360].[tblCatTiposProyectos] ([IDTipoProyecto])
GO
ALTER TABLE [Evaluacion360].[tblWizardItemsTiposProyectos] CHECK CONSTRAINT [Fk_Evaluacion360TblWizardItemsTiposProyectos_Evaluacion360TblCatTiposProyectos_IDTipoProyecto]
GO
ALTER TABLE [Evaluacion360].[tblWizardItemsTiposProyectos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblWizardItemsTiposProyectos_Evaluacion360TblCatWizardItem_IDWizardItem] FOREIGN KEY([IDWizardItem])
REFERENCES [Evaluacion360].[tblCatWizardItem] ([IDWizardItem])
GO
ALTER TABLE [Evaluacion360].[tblWizardItemsTiposProyectos] CHECK CONSTRAINT [Fk_Evaluacion360TblWizardItemsTiposProyectos_Evaluacion360TblCatWizardItem_IDWizardItem]
GO
