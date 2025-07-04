USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblConfGraficasAnalitica](
	[IDConfiguracion] [int] IDENTITY(1,1) NOT NULL,
	[EsGrupo] [bit] NULL,
	[IDProyecto] [int] NULL,
	[IDGrafica] [int] NULL,
	[CopiadoDeIDGrupo] [int] NULL,
	[CopiadoDeIDPregunta] [int] NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360tblConfGraficasAnalitica_IDConfiguracion] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblConfGraficasAnalitica]  WITH CHECK ADD  CONSTRAINT [FK_Evaluacion360tblConfGraficasAnalitica_Evaluacion360tblCatGrupos_CopiadoDeIDGrupo] FOREIGN KEY([CopiadoDeIDGrupo])
REFERENCES [Evaluacion360].[tblCatGrupos] ([IDGrupo])
GO
ALTER TABLE [Evaluacion360].[tblConfGraficasAnalitica] CHECK CONSTRAINT [FK_Evaluacion360tblConfGraficasAnalitica_Evaluacion360tblCatGrupos_CopiadoDeIDGrupo]
GO
ALTER TABLE [Evaluacion360].[tblConfGraficasAnalitica]  WITH CHECK ADD  CONSTRAINT [FK_Evaluacion360tblConfGraficasAnalitica_Evaluacion360tblCatProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
GO
ALTER TABLE [Evaluacion360].[tblConfGraficasAnalitica] CHECK CONSTRAINT [FK_Evaluacion360tblConfGraficasAnalitica_Evaluacion360tblCatProyectos_IDProyecto]
GO
ALTER TABLE [Evaluacion360].[tblConfGraficasAnalitica]  WITH CHECK ADD  CONSTRAINT [FK_Evaluacion360tblConfGraficasAnalitica_InfoDirtblCatGraficas_IDGrafica] FOREIGN KEY([IDGrafica])
REFERENCES [InfoDir].[tblCatGraficas] ([IDGrafica])
GO
ALTER TABLE [Evaluacion360].[tblConfGraficasAnalitica] CHECK CONSTRAINT [FK_Evaluacion360tblConfGraficasAnalitica_InfoDirtblCatGraficas_IDGrafica]
GO
ALTER TABLE [Evaluacion360].[tblConfGraficasAnalitica]  WITH CHECK ADD  CONSTRAINT [FK_Evaluacion360tblConfGraficasAnalitica_SeguridadtblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Evaluacion360].[tblConfGraficasAnalitica] CHECK CONSTRAINT [FK_Evaluacion360tblConfGraficasAnalitica_SeguridadtblUsuarios_IDUsuario]
GO
