USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblEncuestasEmpleados](
	[IDEncuestaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEncuesta] [int] NOT NULL,
	[IDEmpleado] [int] NULL,
	[IDCatEstatus] [int] NOT NULL,
	[FechaAsignacion] [datetime] NULL,
	[FechaUltimaActualizacion] [datetime] NULL,
	[TotalPreguntas] [int] NULL,
	[TotalPreguntasContestadas] [int] NULL,
	[Resultado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RequiereAtencion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_Norma35tblEncuestasEmpleados_IDEncuestaEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDEncuestaEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblEncuestasEmpleados] ADD  CONSTRAINT [d_Norma35tblEncuestasEmpleados_FechaAsignacion]  DEFAULT (getdate()) FOR [FechaAsignacion]
GO
ALTER TABLE [Norma35].[tblEncuestasEmpleados] ADD  CONSTRAINT [D_Norma35TblEncuestasEmpleados_TotalPreguntas]  DEFAULT ((0)) FOR [TotalPreguntas]
GO
ALTER TABLE [Norma35].[tblEncuestasEmpleados] ADD  CONSTRAINT [D_Norma35TblEncuestasEmpleados_TotalPreguntasContestadas]  DEFAULT ((0)) FOR [TotalPreguntasContestadas]
GO
ALTER TABLE [Norma35].[tblEncuestasEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_Norma35tblCatEstatus_Norma35tblEncuestasEmpleados_IDCatEstatus] FOREIGN KEY([IDCatEstatus])
REFERENCES [Norma35].[tblCatEstatus] ([IDCatEstatus])
GO
ALTER TABLE [Norma35].[tblEncuestasEmpleados] CHECK CONSTRAINT [FK_Norma35tblCatEstatus_Norma35tblEncuestasEmpleados_IDCatEstatus]
GO
ALTER TABLE [Norma35].[tblEncuestasEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_Norma35tblEncuesta_Norma35tblEncuestaEmpleado_IDEncuesta] FOREIGN KEY([IDEncuesta])
REFERENCES [Norma35].[tblEncuestas] ([IDEncuesta])
GO
ALTER TABLE [Norma35].[tblEncuestasEmpleados] CHECK CONSTRAINT [FK_Norma35tblEncuesta_Norma35tblEncuestaEmpleado_IDEncuesta]
GO
ALTER TABLE [Norma35].[tblEncuestasEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_Norma35TblEncuestasEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Norma35].[tblEncuestasEmpleados] CHECK CONSTRAINT [FK_RHTblEmpleados_Norma35TblEncuestasEmpleados_IDEmpleado]
GO
