USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatEstatusObjetivosEmpleado](
	[IDEstatusObjetivoEmpleado] [int] NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Orden] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblCatEstatusObjetivosEmpleado_IDEstatusObjetivoEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDEstatusObjetivoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblCatEstatusObjetivosEmpleado] ADD  CONSTRAINT [D_Evaluacion360TblCatEstatusObjetivosEmpleado_Orden]  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [Evaluacion360].[tblCatEstatusObjetivosEmpleado]  WITH CHECK ADD  CONSTRAINT [Chk_Evaluacion360TblCatEstatusObjetivosEmpleado_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Evaluacion360].[tblCatEstatusObjetivosEmpleado] CHECK CONSTRAINT [Chk_Evaluacion360TblCatEstatusObjetivosEmpleado_Traduccion]
GO
