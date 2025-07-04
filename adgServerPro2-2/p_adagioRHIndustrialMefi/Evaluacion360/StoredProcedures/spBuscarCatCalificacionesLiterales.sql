USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Evaluacion360.spBuscarCatCalificacionesLiterales(
	 @IDCalificacionLiteral int	= 0
	,@IDUsuario int
) as

	select 
		IDCalificacionLiteral
		,Literal
		,CalificacionInicial
		,CalificacionFinal
	from Evaluacion360.tblCatCalificacionesLiterales with (nolock)
	where IDCalificacionLiteral = @IDCalificacionLiteral or isnull(@IDCalificacionLiteral,0) = 0 
	order by CalificacionInicial desc
GO
