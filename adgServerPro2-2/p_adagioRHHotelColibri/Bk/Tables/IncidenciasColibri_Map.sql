USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[IncidenciasColibri_Map](
	[IDUsuario] [int] NULL,
	[IDEmpleado] [int] NULL,
	[Fecha] [datetime] NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [Bk].[IncidenciasColibri_Map] ADD  DEFAULT (getdate()) FOR [Fecha]
GO
