USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblRespuestasPreguntas](
	[IDRespuestaPregunta] [int] IDENTITY(1,1) NOT NULL,
	[IDCuestionarioEmpleado] [int] NOT NULL,
	[IDPregunta] [int] NOT NULL,
	[Respuesta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaHoraRespuesta] [datetime] NULL,
	[ValorFinal] [decimal](18, 2) NULL,
 CONSTRAINT [Pk_SaludTblRespuestasPreguntas_IDRespuestaPregunta] PRIMARY KEY CLUSTERED 
(
	[IDRespuestaPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblRespuestasPreguntas] ADD  CONSTRAINT [D_SaludTblRespuestasPreguntas_FechaHoraRespuesta]  DEFAULT (getdate()) FOR [FechaHoraRespuesta]
GO
ALTER TABLE [Salud].[tblRespuestasPreguntas]  WITH CHECK ADD  CONSTRAINT [Fk_SaludTblRespuestasPreguntas_SaludTblCuestionariosEmpleados_IDCuestionarioEmpleado] FOREIGN KEY([IDCuestionarioEmpleado])
REFERENCES [Salud].[tblCuestionariosEmpleados] ([IDCuestionarioEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Salud].[tblRespuestasPreguntas] CHECK CONSTRAINT [Fk_SaludTblRespuestasPreguntas_SaludTblCuestionariosEmpleados_IDCuestionarioEmpleado]
GO
ALTER TABLE [Salud].[tblRespuestasPreguntas]  WITH CHECK ADD  CONSTRAINT [Fk_SaludTblRespuestasPreguntas_SaludTblPreguntas_IDPregunta] FOREIGN KEY([IDPregunta])
REFERENCES [Salud].[tblPreguntas] ([IDPregunta])
GO
ALTER TABLE [Salud].[tblRespuestasPreguntas] CHECK CONSTRAINT [Fk_SaludTblRespuestasPreguntas_SaludTblPreguntas_IDPregunta]
GO
