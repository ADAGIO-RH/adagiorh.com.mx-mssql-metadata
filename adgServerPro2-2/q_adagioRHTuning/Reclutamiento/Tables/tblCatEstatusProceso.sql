USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblCatEstatusProceso](
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MostrarEnProcesoSeleccion] [bit] NULL,
	[Orden] [int] NULL,
	[Color] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstatusProceso] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblCatEstatusProceso] ADD  DEFAULT ('#047bf8') FOR [Color]
GO
