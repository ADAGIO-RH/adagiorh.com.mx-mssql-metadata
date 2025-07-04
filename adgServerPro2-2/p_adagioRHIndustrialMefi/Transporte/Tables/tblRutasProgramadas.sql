USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblRutasProgramadas](
	[IDRutaProgramada] [int] IDENTITY(1,1) NOT NULL,
	[IDRuta] [int] NULL,
	[HoraSalida] [time](7) NULL,
	[HoraLlegada] [time](7) NULL,
	[KMRuta] [int] NULL,
	[Fecha] [date] NULL,
	[FechaCreacion] [datetime] NULL,
	[IDUsuario] [int] NULL,
	[IDRutaHorario] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Transporte].[tblRutasProgramadas] ADD  DEFAULT (getdate()) FOR [FechaCreacion]
GO
