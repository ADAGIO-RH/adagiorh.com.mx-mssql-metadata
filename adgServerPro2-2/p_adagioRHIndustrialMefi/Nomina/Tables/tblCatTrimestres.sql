USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCatTrimestres](
	[IDTrimestre] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Meses] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[MesDiaIni] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MesDiaFin] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MesInicio] [int] NULL,
	[MesFin] [int] NULL,
 CONSTRAINT [Pk_NominaTblCatTrimestres_IDTrimestre] PRIMARY KEY CLUSTERED 
(
	[IDTrimestre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
