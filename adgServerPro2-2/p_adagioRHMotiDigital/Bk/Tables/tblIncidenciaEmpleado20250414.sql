USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblIncidenciaEmpleado20250414](
	[IDIncidenciaEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Fecha] [date] NOT NULL,
	[TiempoSugerido] [time](7) NULL,
	[TiempoAutorizado] [time](7) NULL,
	[Comentario] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CreadoPorIDUsuario] [int] NULL,
	[Autorizado] [bit] NOT NULL,
	[AutorizadoPor] [int] NULL,
	[FechaHoraAutorizacion] [datetime] NULL,
	[FechaHoraCreacion] [datetime] NULL,
	[IDIncapacidadEmpleado] [int] NULL,
	[ComentarioTextoPlano] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TiempoExtraDecimal] [numeric](21, 7) NULL,
	[HorarioAD] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDHorario] [int] NULL,
	[Entrada] [datetime] NULL,
	[Salida] [datetime] NULL,
	[TiempoTrabajado] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPapeleta] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
