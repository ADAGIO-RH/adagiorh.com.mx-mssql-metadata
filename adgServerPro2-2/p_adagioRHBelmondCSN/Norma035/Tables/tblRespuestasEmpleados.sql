USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma035].[tblRespuestasEmpleados](
	[IDRespuesta] [int] IDENTITY(1,1) NOT NULL,
	[IDEncuestaEmpleado] [int] NULL,
	[IDPregunta] [int] NULL,
	[Respuesta] [int] NULL,
	[UltimaActualizacion] [datetime] NULL,
 CONSTRAINT [Pk_Norma035TblRespuestasEmpleados_IDRespuesta] PRIMARY KEY CLUSTERED 
(
	[IDRespuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma035].[tblRespuestasEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_Norma035TblRespuestasEmpleados_Norma035TblCatPreguntas_IDPregunta] FOREIGN KEY([IDPregunta])
REFERENCES [Norma035].[tblCatPreguntas] ([IDPregunta])
GO
ALTER TABLE [Norma035].[tblRespuestasEmpleados] CHECK CONSTRAINT [Fk_Norma035TblRespuestasEmpleados_Norma035TblCatPreguntas_IDPregunta]
GO
