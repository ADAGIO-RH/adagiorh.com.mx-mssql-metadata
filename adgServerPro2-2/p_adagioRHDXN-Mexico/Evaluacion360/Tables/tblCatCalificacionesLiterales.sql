USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblCatCalificacionesLiterales](
	[IDCalificacionLiteral] [int] IDENTITY(1,1) NOT NULL,
	[Literal] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CalificacionInicial] [decimal](10, 2) NOT NULL,
	[CalificacionFinal] [decimal](10, 2) NOT NULL
) ON [PRIMARY]
GO
