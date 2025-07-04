USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblConceptosReporteGeneral](
	[IDReporteMovimiento] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NameReporteConcepto] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescripcionConcepto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[orden] [int] NULL,
	[IDReporteMovimientoPadre] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoDato] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
