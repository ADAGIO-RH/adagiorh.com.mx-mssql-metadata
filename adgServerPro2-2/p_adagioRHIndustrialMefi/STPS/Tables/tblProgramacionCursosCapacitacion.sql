USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [STPS].[tblProgramacionCursosCapacitacion](
	[IDProgramacionCursoCapacitacion] [int] IDENTITY(1,1) NOT NULL,
	[IDCursoCapacitacion] [int] NOT NULL,
	[Duracion] [decimal](10, 2) NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[IDModalidad] [int] NOT NULL,
	[IDAgenteCapacitacion] [int] NOT NULL,
 CONSTRAINT [PK_STPStblProgramacionCursosCapacitacion_IDProgramacionCursoCapacitacion] PRIMARY KEY CLUSTERED 
(
	[IDProgramacionCursoCapacitacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblProgramacionCursosCapacitacion_FechaFin] ON [STPS].[tblProgramacionCursosCapacitacion]
(
	[FechaFin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblProgramacionCursosCapacitacion_Fechaini] ON [STPS].[tblProgramacionCursosCapacitacion]
(
	[FechaIni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblProgramacionCursosCapacitacion_FechaIni_FechaFin] ON [STPS].[tblProgramacionCursosCapacitacion]
(
	[FechaIni] ASC,
	[FechaFin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblProgramacionCursosCapacitacion_IDAgenteCapacitacion] ON [STPS].[tblProgramacionCursosCapacitacion]
(
	[IDAgenteCapacitacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblProgramacionCursosCapacitacion_IDCursoCapacitacion] ON [STPS].[tblProgramacionCursosCapacitacion]
(
	[IDCursoCapacitacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblProgramacionCursosCapacitacion_IDModalidad] ON [STPS].[tblProgramacionCursosCapacitacion]
(
	[IDModalidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacion]  WITH CHECK ADD  CONSTRAINT [FK_STPStblAgentesCapacitacion_STPStblProgramacionCursosCapacitacion_IDAgenteCapacitacion] FOREIGN KEY([IDAgenteCapacitacion])
REFERENCES [STPS].[tblAgentesCapacitacion] ([IDAgenteCapacitacion])
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacion] CHECK CONSTRAINT [FK_STPStblAgentesCapacitacion_STPStblProgramacionCursosCapacitacion_IDAgenteCapacitacion]
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacion]  WITH CHECK ADD  CONSTRAINT [FK_STPStblCatModalidades_STPStblProgramacionCursosCapacitacion_IDModalidad] FOREIGN KEY([IDModalidad])
REFERENCES [STPS].[tblCatModalidades] ([IDModalidad])
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacion] CHECK CONSTRAINT [FK_STPStblCatModalidades_STPStblProgramacionCursosCapacitacion_IDModalidad]
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacion]  WITH CHECK ADD  CONSTRAINT [FK_STPStblCursosCapacitacion_STPStblProgramacionCursosCapacitacion_IDCursoCapacitacion] FOREIGN KEY([IDCursoCapacitacion])
REFERENCES [STPS].[tblCursosCapacitacion] ([IDCursoCapacitacion])
GO
ALTER TABLE [STPS].[tblProgramacionCursosCapacitacion] CHECK CONSTRAINT [FK_STPStblCursosCapacitacion_STPStblProgramacionCursosCapacitacion_IDCursoCapacitacion]
GO
