USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblCatTurnos](
	[IDTurno] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoJornadaSAT] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_AsistenciaTblCatTurnos_IDTurno] PRIMARY KEY CLUSTERED 
(
	[IDTurno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_AsistenciatblCatTurnos_Descripcion] UNIQUE NONCLUSTERED 
(
	[Descripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblCatTurnos]  WITH CHECK ADD  CONSTRAINT [Fk_AsistenciaTblCatTurnos_IDTipoJornadaSAT] FOREIGN KEY([IDTipoJornadaSAT])
REFERENCES [Sat].[tblCatTiposJornada] ([IDTipoJornada])
GO
ALTER TABLE [Asistencia].[tblCatTurnos] CHECK CONSTRAINT [Fk_AsistenciaTblCatTurnos_IDTipoJornadaSAT]
GO
