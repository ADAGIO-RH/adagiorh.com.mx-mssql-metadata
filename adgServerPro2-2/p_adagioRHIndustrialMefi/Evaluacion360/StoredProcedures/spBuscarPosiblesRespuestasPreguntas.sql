USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Evaluacion360].[spBuscarPosiblesRespuestasPreguntas](
	@IDPregunta int
) as
	
	select IDPosibleRespuesta
		,IDPregunta
		,OpcionRespuesta
		,isnull(Valor,0) Valor
		,isnull(CreadoParaIDTipoPregunta,0) as CreadoParaIDTipoPregunta
	from Evaluacion360.tblPosiblesRespuestasPreguntas
	where IDPregunta = @IDPregunta
	Order by IDPosibleRespuesta asc
GO
