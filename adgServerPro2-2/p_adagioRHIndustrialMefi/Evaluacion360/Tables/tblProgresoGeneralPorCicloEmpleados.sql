USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblProgresoGeneralPorCicloEmpleados](
	[IDProgresoGeneralPorCicloEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDCicloMedicionObjetivo] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Porcentaje] [decimal](18, 2) NOT NULL,
 CONSTRAINT [Pk_Evaluacion360TblProgresoGeneralPorCicloEmpleados_IDProgresoGeneralPorCicloEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDProgresoGeneralPorCicloEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblProgresoGeneralPorCicloEmpleados] ADD  CONSTRAINT [D_Evaluacion360TblProgresoGeneralPorCicloEmpleados_Porcentaje]  DEFAULT ((0)) FOR [Porcentaje]
GO
ALTER TABLE [Evaluacion360].[tblProgresoGeneralPorCicloEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblProgresoGeneralPorCicloEmpleados_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblProgresoGeneralPorCicloEmpleados] CHECK CONSTRAINT [Fk_Evaluacion360TblProgresoGeneralPorCicloEmpleados_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [Evaluacion360].[tblProgresoGeneralPorCicloEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_TblProgresoGeneralPorCicloEmpleados_Evaluacion360TblCatCiclosMedicionObjetivos_IDCicloMedicionObjetivo] FOREIGN KEY([IDCicloMedicionObjetivo])
REFERENCES [Evaluacion360].[tblCatCiclosMedicionObjetivos] ([IDCicloMedicionObjetivo])
ON DELETE CASCADE
GO
ALTER TABLE [Evaluacion360].[tblProgresoGeneralPorCicloEmpleados] CHECK CONSTRAINT [Fk_TblProgresoGeneralPorCicloEmpleados_Evaluacion360TblCatCiclosMedicionObjetivos_IDCicloMedicionObjetivo]
GO
