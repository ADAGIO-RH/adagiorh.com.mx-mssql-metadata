USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc Reportes.spMiReporte(
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly
	,@IDUsuario int
) as
	select *
	from reportes.tblcatreportesbasicos
GO
