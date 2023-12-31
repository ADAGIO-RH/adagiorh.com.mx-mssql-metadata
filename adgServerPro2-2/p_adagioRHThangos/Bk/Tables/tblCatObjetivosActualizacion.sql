USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatObjetivosActualizacion](
	[IDObjetivo] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCicloMedicionObjetivo] [int] NOT NULL,
	[IDTipoMedicionObjetivo] [int] NOT NULL,
	[IDEstatusObjetivo] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHoraReg] [datetime] NOT NULL,
	[Progreso] [decimal](18, 2) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
