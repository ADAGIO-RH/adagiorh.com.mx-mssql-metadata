USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Transporte].[tblCatReporteMovimientos](
	[IDReporteMovimiento] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NameReporteMovimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Orden] [int] NULL,
	[TipoDato] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [Transporte].[tblCatReporteMovimientos] ADD  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [Transporte].[tblCatReporteMovimientos] ADD  DEFAULT ('') FOR [TipoDato]
GO
