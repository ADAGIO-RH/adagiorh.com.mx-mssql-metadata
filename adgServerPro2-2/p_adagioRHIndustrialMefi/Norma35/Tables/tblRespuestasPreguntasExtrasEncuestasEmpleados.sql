USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados](
	[IDRespuestaPreguntaExtraEncuestaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEncuestaEmpleado] [int] NOT NULL,
	[IDPreguntaExtraEncuesta] [int] NOT NULL,
	[Respuesta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaHoraRegistro] [datetime] NULL,
 CONSTRAINT [Pk_Norma35TblRespuestasPreguntasExtrasEncuestasEmpleados_IDRespuestaPreguntaExtraEncuestaEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDRespuestaPreguntaExtraEncuestaEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_Norma35TblRespuestasPreguntasExtrasEncuestasEmpleados_IDPreguntaExtraEncuesta] UNIQUE NONCLUSTERED 
(
	[IDPreguntaExtraEncuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados] ADD  CONSTRAINT [D_Norma35TblRespuestasPreguntasExtrasEncuestasEmpleados_FechaHoraRegistro]  DEFAULT (getdate()) FOR [FechaHoraRegistro]
GO
ALTER TABLE [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblEncuestasEmpleados_Norma35TblRespuestasPreguntasExtrasEncuestasEmpleados_IDEncuestaEmpleado] FOREIGN KEY([IDEncuestaEmpleado])
REFERENCES [Norma35].[tblEncuestasEmpleados] ([IDEncuestaEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados] CHECK CONSTRAINT [Fk_Norma35TblEncuestasEmpleados_Norma35TblRespuestasPreguntasExtrasEncuestasEmpleados_IDEncuestaEmpleado]
GO
ALTER TABLE [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblPreguntasExtraEncuesta_Norma35TblRespuestasPreguntasExtrasEncuestasEmpleados_IDPreguntaExtraEncuesta] FOREIGN KEY([IDPreguntaExtraEncuesta])
REFERENCES [Norma35].[tblPreguntasExtrasEncuestas] ([IDPreguntaExtraEncuesta])
GO
ALTER TABLE [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados] CHECK CONSTRAINT [Fk_Norma35TblPreguntasExtraEncuesta_Norma35TblRespuestasPreguntasExtrasEncuestasEmpleados_IDPreguntaExtraEncuesta]
GO
