USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblBkLectoresZK](
	[IDLector] [int] NULL,
	[IDEmpleado] [int] NULL,
	[Checada] [datetime] NULL,
	[FechaHora] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_AsistenciaTblBKLectoresZK_IDEmpleado_Checada] ON [Asistencia].[tblBkLectoresZK]
(
	[IDEmpleado] ASC,
	[Checada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
