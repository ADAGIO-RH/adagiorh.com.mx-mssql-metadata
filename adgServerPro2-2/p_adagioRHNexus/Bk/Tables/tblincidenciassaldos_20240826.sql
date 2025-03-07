USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblincidenciassaldos_20240826](
	[IDIncidenciaSaldo] [int] IDENTITY(1,1) NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NOT NULL
) ON [PRIMARY]
GO
