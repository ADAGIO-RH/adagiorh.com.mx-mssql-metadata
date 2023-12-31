USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblpapeletas](
	[IDPapeleta] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaFin] [date] NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[TiempoAutorizado] [time](7) NULL,
	[TiempoSugerido] [time](7) NULL,
	[Dias] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Duracion] [int] NULL,
	[IDClasificacionIncapacidad] [int] NULL,
	[IDTipoIncapacidad] [int] NULL,
	[IDTipoLesion] [int] NULL,
	[IDTipoRiesgoIncapacidad] [int] NULL,
	[Numero] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PagoSubsidioEmpresa] [bit] NULL,
	[Permanente] [bit] NULL,
	[DiasDescanso] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Fecha] [date] NULL,
	[Comentario] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ComentarioTextoPlano] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Autorizado] [bit] NULL,
	[FechaHora] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
	[PapeletaAutorizada] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
