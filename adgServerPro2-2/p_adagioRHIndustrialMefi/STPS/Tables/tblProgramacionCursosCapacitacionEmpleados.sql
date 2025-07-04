USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [STPS].[tblProgramacionCursosCapacitacionEmpleados](
	[IDProgramacionCursosCapacitacionEmpleados] [int] IDENTITY(1,1) NOT NULL,
	[IDProgramacionCursoCapacitacion] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Fecha] [datetime] NULL,
	[IDEstatusCursoEmpleados] [int] NULL,
	[Calificacion] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_STPStblProgramacionCursosCapacitacionEmpleados_IDProgramacionCursosCapacitacionEmpleados] PRIMARY KEY CLUSTERED 
(
	[IDProgramacionCursosCapacitacionEmpleados] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblProgramacionCursosCapacitacionEmpleados_IDEmpleado] ON [STPS].[tblProgramacionCursosCapacitacionEmpleados]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblProgramacionCursosCapacitacionEmpleados_IDEstatusCursoEmpleados] ON [STPS].[tblProgramacionCursosCapacitacionEmpleados]
(
	[IDEstatusCursoEmpleados] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblProgramacionCursosCapacitacionEmpleados_IDProgramacionCursoCapacitacion] ON [STPS].[tblProgramacionCursosCapacitacionEmpleados]
(
	[IDProgramacionCursoCapacitacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacionEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_STPStblProgramacionCursosCapacitacionEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacionEmpleados] CHECK CONSTRAINT [FK_RHTblEmpleados_STPStblProgramacionCursosCapacitacionEmpleados_IDEmpleado]
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacionEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_STPStblEstatusCursosEmpleados_STPStblProgramacionCursosCapacitacionEmpleados_IDEstatusCursoEmpleados] FOREIGN KEY([IDEstatusCursoEmpleados])
REFERENCES [STPS].[tblEstatusCursosEmpleados] ([IDEstatusCursoEmpleados])
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacionEmpleados] CHECK CONSTRAINT [FK_STPStblEstatusCursosEmpleados_STPStblProgramacionCursosCapacitacionEmpleados_IDEstatusCursoEmpleados]
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacionEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_STPStblProgramacionCursosCapacitacion_STPStblProgramacionCursosCapacitacionEmpleados_IDProgramacionCursoCapacitacion] FOREIGN KEY([IDProgramacionCursoCapacitacion])
REFERENCES [STPS].[tblProgramacionCursosCapacitacion] ([IDProgramacionCursoCapacitacion])
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacionEmpleados] CHECK CONSTRAINT [FK_STPStblProgramacionCursosCapacitacion_STPStblProgramacionCursosCapacitacionEmpleados_IDProgramacionCursoCapacitacion]
GO
