USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEstatusProyectos](
	[IDEstatusProyecto] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[IDEstatus] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaCreacion] [datetime] NULL,
 CONSTRAINT [Pk_Evaluacion360TblEstatusProyectos_IDEstatusProyecto] PRIMARY KEY CLUSTERED 
(
	[IDEstatusProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEstatusProyectos] ADD  CONSTRAINT [D_Evaluacion360TblEstatusProyectos_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Evaluacion360].[tblEstatusProyectos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEstatusProyectos_IDEstatus] FOREIGN KEY([IDEstatus])
REFERENCES [Evaluacion360].[tblCatEstatus] ([IDEstatus])
GO
ALTER TABLE [Evaluacion360].[tblEstatusProyectos] CHECK CONSTRAINT [Fk_Evaluacion360TblEstatusProyectos_IDEstatus]
GO
ALTER TABLE [Evaluacion360].[tblEstatusProyectos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEstatusProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblEstatusProyectos] CHECK CONSTRAINT [Fk_Evaluacion360TblEstatusProyectos_IDProyecto]
GO
ALTER TABLE [Evaluacion360].[tblEstatusProyectos]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblEstatusProyectos_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Evaluacion360].[tblEstatusProyectos] CHECK CONSTRAINT [Fk_Evaluacion360TblEstatusProyectos_IDUsuario]
GO
