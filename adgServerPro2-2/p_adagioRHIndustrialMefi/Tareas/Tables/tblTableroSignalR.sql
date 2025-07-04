USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tareas].[tblTableroSignalR](
	[IDReferencia] [int] NULL,
	[IDTipoTablero] [int] NULL,
	[IDUsuario] [int] NULL,
	[Token] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConnectionId] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaRegistro] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Tareas].[tblTableroSignalR] ADD  DEFAULT (getdate()) FOR [FechaRegistro]
GO
