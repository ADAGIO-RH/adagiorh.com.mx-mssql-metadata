USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatTiposProyectos](
	[IDTipoProyecto] [int] NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Activo] [bit] NOT NULL,
	[Configuracion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatTiposProyectos_IDTipoProyecto] PRIMARY KEY CLUSTERED 
(
	[IDTipoProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatTiposProyectos] ADD  CONSTRAINT [D_Evaluacion360TblCatTiposProyectos_Activo]  DEFAULT (CONVERT([bit],(0))) FOR [Activo]
GO
ALTER TABLE [Evaluacion360].[tblCatTiposProyectos]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360TblCatTiposProyectos_Configuracion] CHECK  ((isjson([Configuracion])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatTiposProyectos] CHECK CONSTRAINT [Chk_Evaluacion360TblCatTiposProyectos_Configuracion]
GO
