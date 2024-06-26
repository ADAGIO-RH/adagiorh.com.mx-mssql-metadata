USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblsolicitudesempleadomarzo2024](
	[IDSolicitud] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoSolicitud] [int] NOT NULL,
	[IDEstatusSolicitud] [int] NOT NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIni] [date] NULL,
	[CantidadDias] [int] NULL,
	[FechaCreacion] [datetime] NULL,
	[ComentarioEmpleado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ComentarioSupervisor] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CantidadMonto] [decimal](18, 2) NULL,
	[IDUsuarioAutoriza] [int] NULL,
	[DiasDescanso] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaFin] [date] NULL,
	[DiasDisponibles] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
