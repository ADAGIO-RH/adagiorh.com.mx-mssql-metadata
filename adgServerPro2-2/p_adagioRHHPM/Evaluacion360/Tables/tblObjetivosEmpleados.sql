USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblObjetivosEmpleados](
	[IDObjetivoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDObjetivo] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Objetivo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Actual] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Peso] [decimal](18, 2) NOT NULL,
	[PorcentajeAlcanzado] [decimal](18, 2) NOT NULL,
	[IDEstatusObjetivoEmpleado] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHoraReg] [datetime] NOT NULL,
	[UltimaActualizacion] [datetime] NULL,
 CONSTRAINT [Pk_Evaluacion360TblObjetivosEmpleados_IDObjetivoEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDObjetivoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados] ADD  CONSTRAINT [D_Evaluacion360TblObjetivosEmpleados_Peso]  DEFAULT ((0)) FOR [Peso]
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados] ADD  CONSTRAINT [D_Evaluacion360TblObjetivosEmpleados_PorcentajeAlcanzado]  DEFAULT ((0)) FOR [PorcentajeAlcanzado]
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados] ADD  CONSTRAINT [D_Evaluacion360TblObjetivosEmpleados_FechaHoraReg]  DEFAULT (getdate()) FOR [FechaHoraReg]
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados] ADD  CONSTRAINT [D_Evaluacion360TblObjetivosEmpleados_UltimaActualizacion]  DEFAULT (getdate()) FOR [UltimaActualizacion]
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblObjetivosEmpleados_Evaluacion360TblCatEstatusObjetivosEmpleado_IDEstatusObjetivoEmpleado] FOREIGN KEY([IDEstatusObjetivoEmpleado])
REFERENCES [Evaluacion360].[tblCatEstatusObjetivosEmpleado] ([IDEstatusObjetivoEmpleado])
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados] CHECK CONSTRAINT [Fk_Evaluacion360TblObjetivosEmpleados_Evaluacion360TblCatEstatusObjetivosEmpleado_IDEstatusObjetivoEmpleado]
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblObjetivosEmpleados_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados] CHECK CONSTRAINT [Fk_Evaluacion360TblObjetivosEmpleados_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TbObjetivosEmpleados_Evaluacion360TblCatObjetivos_IDObjetivo] FOREIGN KEY([IDObjetivo])
REFERENCES [Evaluacion360].[tblCatObjetivos] ([IDObjetivo])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados] CHECK CONSTRAINT [Fk_Evaluacion360TbObjetivosEmpleados_Evaluacion360TblCatObjetivos_IDObjetivo]
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados]  WITH CHECK ADD  CONSTRAINT [FkEvaluacion360TblObjetivosEmpleados_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Evaluacion360].[tblObjetivosEmpleados] CHECK CONSTRAINT [FkEvaluacion360TblObjetivosEmpleados_SeguridadTblUsuarios_IDUsuario]
GO
