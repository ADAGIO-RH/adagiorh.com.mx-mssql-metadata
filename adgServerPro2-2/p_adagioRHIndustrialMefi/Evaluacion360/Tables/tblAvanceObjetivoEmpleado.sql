USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblAvanceObjetivoEmpleado](
	[IDAvanceObjetivoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDObjetivoEmpleado] [int] NOT NULL,
	[Valor] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fecha] [datetime] NOT NULL,
	[FechaCaptura] [datetime] NOT NULL,
	[Comentario] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360tblAvanceObjetivoEmpleado_IDAvanceObjetivoEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDAvanceObjetivoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblAvanceObjetivoEmpleado] ADD  CONSTRAINT [D_Evaluacion360tblAvanceObjetivoEmpleado_FechaCaptura]  DEFAULT (getdate()) FOR [FechaCaptura]
GO
ALTER TABLE [Evaluacion360].[tblAvanceObjetivoEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360tblAvanceObjetivoEmpleado_Evaluacion360TblObjetivosEmpleados_IDObjetivoEmpleado] FOREIGN KEY([IDObjetivoEmpleado])
REFERENCES [Evaluacion360].[tblObjetivosEmpleados] ([IDObjetivoEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblAvanceObjetivoEmpleado] CHECK CONSTRAINT [Fk_Evaluacion360tblAvanceObjetivoEmpleado_Evaluacion360TblObjetivosEmpleados_IDObjetivoEmpleado]
GO
ALTER TABLE [Evaluacion360].[tblAvanceObjetivoEmpleado]  WITH CHECK ADD  CONSTRAINT [FkEvaluacion360tblAvanceObjetivoEmpleado_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Evaluacion360].[tblAvanceObjetivoEmpleado] CHECK CONSTRAINT [FkEvaluacion360tblAvanceObjetivoEmpleado_SeguridadTblUsuarios_IDUsuario]
GO
