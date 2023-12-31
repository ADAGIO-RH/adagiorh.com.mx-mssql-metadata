USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatProyectos20230315](
	[IDProyecto] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCreacion] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
	[TotalPruebasARealizar] [int] NULL,
	[TotalPruebasRealizadas] [int] NULL,
	[Progreso] [int] NULL,
	[FechaInicio] [date] NULL,
	[FechaFin] [date] NULL,
	[Calendarizado] [bit] NULL,
	[IDTask] [int] NULL,
	[IDSchedule] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
