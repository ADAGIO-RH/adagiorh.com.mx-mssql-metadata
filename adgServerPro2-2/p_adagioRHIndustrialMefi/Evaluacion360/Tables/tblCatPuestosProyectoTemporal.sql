USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatPuestosProyectoTemporal](
	[IDProyecto] [int] NOT NULL,
	[NombrePuesto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
