USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEscalasValoracionesProyectos](
	[IDEscalaValoracionProyecto] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Valor] [float] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblEscalasValoracionesProyectos_IDEscalaValoracionProyecto] PRIMARY KEY CLUSTERED 
(
	[IDEscalaValoracionProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblEscalasValoracionesProyectos] ADD  CONSTRAINT [DF__tblEscala__Valor__000AF8CF]  DEFAULT ((0)) FOR [Valor]
GO
ALTER TABLE [Evaluacion360].[tblEscalasValoracionesProyectos]  WITH CHECK ADD  CONSTRAINT [Pk_Evaluacion360TblEscalasValoracionesProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblEscalasValoracionesProyectos] CHECK CONSTRAINT [Pk_Evaluacion360TblEscalasValoracionesProyectos_IDProyecto]
GO
