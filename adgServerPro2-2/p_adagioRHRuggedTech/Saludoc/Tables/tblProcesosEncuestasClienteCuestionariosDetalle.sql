USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle](
	[IDProcesoEncuestaDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDProcesoEncuesta] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDCatCuestionario] [int] NOT NULL,
	[IDCatPregunta] [int] NOT NULL,
	[Respuesta] [int] NULL,
 CONSTRAINT [PK_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_IDProcesoEncuestaDetalle] PRIMARY KEY CLUSTERED 
(
	[IDProcesoEncuestaDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle] ADD  CONSTRAINT [df_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_Respuesta]  DEFAULT ((0)) FOR [Respuesta]
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_RHTBlEmpleados_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle] CHECK CONSTRAINT [FK_RHTBlEmpleados_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_IDEmpleado]
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SaludocTblCatCuestionarios_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_IDCuestionario] FOREIGN KEY([IDCatCuestionario])
REFERENCES [Saludoc].[TblCatCuestionarios] ([IDCatCuestionario])
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle] CHECK CONSTRAINT [FK_SaludocTblCatCuestionarios_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_IDCuestionario]
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SaludocTblCatPreguntasCuestionario_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_IDPregunta] FOREIGN KEY([IDCatPregunta])
REFERENCES [Saludoc].[TblCatPreguntasCuestionario] ([IDCatPregunta])
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle] CHECK CONSTRAINT [FK_SaludocTblCatPreguntasCuestionario_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_IDPregunta]
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle]  WITH CHECK ADD  CONSTRAINT [FK_SaludocTblProcesosEncuestasCliente_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_IDProcesoEncuesta] FOREIGN KEY([IDProcesoEncuesta])
REFERENCES [Saludoc].[tblProcesosEncuestasCliente] ([IDProcesoEncuesta])
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasClienteCuestionariosDetalle] CHECK CONSTRAINT [FK_SaludocTblProcesosEncuestasCliente_SaludocTblProcesosEncuestasClienteCuestionariosDetalle_IDProcesoEncuesta]
GO
