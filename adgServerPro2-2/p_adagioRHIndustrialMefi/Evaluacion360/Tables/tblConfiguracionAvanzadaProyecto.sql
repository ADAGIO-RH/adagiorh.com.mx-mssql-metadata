USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblConfiguracionAvanzadaProyecto](
	[IDConfiguracionAvanzada] [int] NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[Valor] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblConfiguracionAvanzadaProyecto_IDConfiguracionAvanzadaIDProyecto] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracionAvanzada] ASC,
	[IDProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblConfiguracionAvanzadaProyecto]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblConfiguracionesAvanzadas_Evaluacion360TblCatProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblConfiguracionAvanzadaProyecto] CHECK CONSTRAINT [Fk_Evaluacion360TblConfiguracionesAvanzadas_Evaluacion360TblCatProyectos_IDProyecto]
GO
ALTER TABLE [Evaluacion360].[tblConfiguracionAvanzadaProyecto]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblConfiguracionesAvanzadas_Evaluacion360TblConfiguracionAvanzadaProyecto_IDConfiguracionAvanzada] FOREIGN KEY([IDConfiguracionAvanzada])
REFERENCES [Evaluacion360].[tblConfiguracionesAvanzadas] ([IDConfiguracionAvanzada])
GO
ALTER TABLE [Evaluacion360].[tblConfiguracionAvanzadaProyecto] CHECK CONSTRAINT [Fk_Evaluacion360TblConfiguracionesAvanzadas_Evaluacion360TblConfiguracionAvanzadaProyecto_IDConfiguracionAvanzada]
GO
