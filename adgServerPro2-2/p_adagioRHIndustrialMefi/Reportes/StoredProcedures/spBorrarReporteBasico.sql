USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc Reportes.spBorrarReporteBasico(
	@IDReporteBasico int
	,@IDUsuario int
) as
	delete from Reportes.tblCatReportesBasicos where IDReporteBasico = @IDReporteBasico
GO
