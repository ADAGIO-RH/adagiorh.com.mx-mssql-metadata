USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblContactosEmpleadosTiposNotificaciones_2024_10_24](
	[IDContactoEmpleadoTipoNotificacion] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTemplateNotificacion] [int] NOT NULL,
	[IDContactoEmpleado] [int] NULL
) ON [PRIMARY]
GO
