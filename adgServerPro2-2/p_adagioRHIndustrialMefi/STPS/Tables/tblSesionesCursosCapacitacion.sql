USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [STPS].[tblSesionesCursosCapacitacion](
	[IDSesion] [int] IDENTITY(1,1) NOT NULL,
	[IDProgramacionCursoCapacitacion] [int] NOT NULL,
	[IDSalaCapacitacion] [int] NULL,
	[FechaHoraInicial] [datetime] NULL,
	[FechaHoraFinal] [datetime] NULL,
 CONSTRAINT [PK_STPStblSesionesCursosCapacitacion_IDSesion] PRIMARY KEY CLUSTERED 
(
	[IDSesion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblSesionesCursosCapacitacion_IDProgramacionCursoCapacitacion] ON [STPS].[tblSesionesCursosCapacitacion]
(
	[IDProgramacionCursoCapacitacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_STPStblSesionesCursosCapacitacion_IDSalaCapacitacion] ON [STPS].[tblSesionesCursosCapacitacion]
(
	[IDSalaCapacitacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [STPS].[tblSesionesCursosCapacitacion]  WITH CHECK ADD  CONSTRAINT [FK_STPStblProgramacionCursosCapacitacion_STPStblSesionesCursosCapacitacion_IDProgramacionCursoCapacitacion] FOREIGN KEY([IDProgramacionCursoCapacitacion])
REFERENCES [STPS].[tblProgramacionCursosCapacitacion] ([IDProgramacionCursoCapacitacion])
GO
ALTER TABLE [STPS].[tblSesionesCursosCapacitacion] CHECK CONSTRAINT [FK_STPStblProgramacionCursosCapacitacion_STPStblSesionesCursosCapacitacion_IDProgramacionCursoCapacitacion]
GO
ALTER TABLE [STPS].[tblSesionesCursosCapacitacion]  WITH CHECK ADD  CONSTRAINT [FK_STPStblSalasCapacitacion_STPStblSesionesCursosCapacitacion_IDSalaCapacitacion] FOREIGN KEY([IDSalaCapacitacion])
REFERENCES [STPS].[tblSalasCapacitacion] ([IDSalaCapacitacion])
GO
ALTER TABLE [STPS].[tblSesionesCursosCapacitacion] CHECK CONSTRAINT [FK_STPStblSalasCapacitacion_STPStblSesionesCursosCapacitacion_IDSalaCapacitacion]
GO
