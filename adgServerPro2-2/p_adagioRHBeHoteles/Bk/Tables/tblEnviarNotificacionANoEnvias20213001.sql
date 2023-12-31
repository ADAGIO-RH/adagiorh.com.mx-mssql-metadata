USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblEnviarNotificacionANoEnvias20213001](
	[IDEnviarNotificacionA] [int] IDENTITY(1,1) NOT NULL,
	[IDNotifiacion] [int] NOT NULL,
	[IDMedioNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Destinatario] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Enviado] [bit] NULL,
	[FechaHoraEnvio] [datetime] NULL,
	[FechaHoraCreacion] [datetime] NULL,
	[Adjuntos] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NuevoAdjuntos] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
