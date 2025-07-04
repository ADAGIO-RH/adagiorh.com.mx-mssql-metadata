USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc RH.spBorrarReporteEvaluacionRenovacionContratoImpresa(
	@IDReporteEvaluacionRenovacionContratoImpresa int
	,@IDUsuario int
) as

	exec  RH.spBuscarReportesEvaluacionesRenovacionContratosImpresas
		@IDReporteEvaluacionRenovacionContratoImpresa = @IDReporteEvaluacionRenovacionContratoImpresa,
		@IDUsuario = @IDUsuario

	delete RH.tblReportesEvaluacionesRenovacionContratosImpresas
	where IDReporteEvaluacionRenovacionContratoImpresa = @IDReporteEvaluacionRenovacionContratoImpresa
GO
