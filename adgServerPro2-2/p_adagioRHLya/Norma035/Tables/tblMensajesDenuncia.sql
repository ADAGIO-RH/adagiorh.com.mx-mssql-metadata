USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma035].[tblMensajesDenuncia](
	[IDMensajeDenuncia] [int] IDENTITY(1,1) NOT NULL,
	[IDDenuncia] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
	[Texto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
