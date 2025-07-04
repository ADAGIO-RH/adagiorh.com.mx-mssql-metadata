USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   proc RH.spIReporteEvaluacionRenovacionContratoImpresa(
	@IDReporteEvaluacionRenovacionContratoImpresa int 
	,@IDReporteBasico int
	,@IDUsuario int 
) as
	if (ISNULL(@IDReporteEvaluacionRenovacionContratoImpresa, 0) = 0)
	begin
		insert into RH.tblReportesEvaluacionesRenovacionContratosImpresas(IDReporteBasico, IDUsuario)
		values (@IDReporteBasico, @IDUsuario)

		set @IDReporteEvaluacionRenovacionContratoImpresa = SCOPE_IDENTITY()
	end else
	begin
		update RH.tblReportesEvaluacionesRenovacionContratosImpresas
			set
				IDReporteBasico = @IDReporteBasico
		where IDReporteEvaluacionRenovacionContratoImpresa = @IDReporteEvaluacionRenovacionContratoImpresa
	end

	exec RH.spBuscarReportesEvaluacionesRenovacionContratosImpresas
		@IDReporteEvaluacionRenovacionContratoImpresa = @IDReporteEvaluacionRenovacionContratoImpresa,
		@IDUsuario = @IDUsuario
GO
