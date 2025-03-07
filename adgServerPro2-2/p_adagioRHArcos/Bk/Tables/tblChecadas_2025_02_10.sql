USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblChecadas_2025_02_10](
	[IDChecada] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[FechaOrigen] [date] NULL,
	[IDLector] [int] NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoChecada] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NULL,
	[Comentario] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDZonaHoraria] [int] NULL,
	[Automatica] [bit] NULL,
	[FechaReg] [datetime] NOT NULL,
	[FechaOriginal] [datetime] NULL,
	[Latitud] [float] NULL,
	[Longitud] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
