USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblCatHorarios](
	[IDHorario] [int] IDENTITY(1,1) NOT NULL,
	[IDTurno] [int] NOT NULL,
	[Codigo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[HoraEntrada] [time](7) NOT NULL,
	[HoraSalida] [time](7) NOT NULL,
	[TiempoDescanso] [time](7) NOT NULL,
	[JornadaLaboral] [time](7) NOT NULL,
	[TiempoTotal] [time](7) NOT NULL,
	[HoraDescanso] [time](7) NULL,
 CONSTRAINT [Pk_AsistenciatblCatHorarios_IDHorario] PRIMARY KEY CLUSTERED 
(
	[IDHorario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AsistenciatblCatHorarios_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_tblCatHorarios_Descripcion] UNIQUE NONCLUSTERED 
(
	[Descripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciatblCatHorarios_IDTurno] ON [Asistencia].[tblCatHorarios]
(
	[IDTurno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblCatHorarios]  WITH CHECK ADD  CONSTRAINT [U_AsistenciatblCatHorarios_IDTurno] FOREIGN KEY([IDTurno])
REFERENCES [Asistencia].[tblCatTurnos] ([IDTurno])
GO
ALTER TABLE [Asistencia].[tblCatHorarios] CHECK CONSTRAINT [U_AsistenciatblCatHorarios_IDTurno]
GO
ALTER TABLE [Asistencia].[tblCatHorarios]  WITH CHECK ADD  CONSTRAINT [NoSpaces_AsistenciatblCatHorarios_Codigo] CHECK  ((NOT [Codigo] like '% %'))
GO
ALTER TABLE [Asistencia].[tblCatHorarios] CHECK CONSTRAINT [NoSpaces_AsistenciatblCatHorarios_Codigo]
GO
