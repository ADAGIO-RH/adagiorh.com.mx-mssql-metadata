USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblPapeletaPeriodo](
	[IDPapeleta] [int] NOT NULL,
	[IDUsuario] [int] NULL,
	[Periodo] [int] NULL,
	[Fecha] [date] NULL,
	[Duracion] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDPapeleta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblPapeletaPeriodo]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciatblPapeletaPeriodo_IDPapeleta] FOREIGN KEY([IDPapeleta])
REFERENCES [Asistencia].[tblPapeletas] ([IDPapeleta])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Asistencia].[tblPapeletaPeriodo] CHECK CONSTRAINT [FK_AsistenciatblPapeletaPeriodo_IDPapeleta]
GO
