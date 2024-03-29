USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblConfigReporteVariablesBimestrales_2024_01_01](
	[IDConfiguracionVariablesbimestrales] [int] IDENTITY(1,1) NOT NULL,
	[ConceptosValesDespensa] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosPremioPuntualidad] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosPremioAsistencia] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosHorasExtrasDobles] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosIntegrablesVariables] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosDias] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRazonMovimiento] [int] NOT NULL,
	[CriterioDias] [bit] NULL,
	[PromediarUMA] [int] NULL,
	[TopePremioPuntualidadAsistencia] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
