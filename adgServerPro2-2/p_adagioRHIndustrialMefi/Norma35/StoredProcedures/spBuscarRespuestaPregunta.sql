USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Norma35].[spBuscarRespuestaPregunta](
	@IDCatPregunta int
) as
	select
		IDRespuestaPregunta
		,IDCatPregunta
		,Respuesta
		,isnull(FechaRespuesta,'1990-01-01') as FechaRespuesta
		,isnull(ValorFinal,0.00) as ValorFinal
	from [Norma35].[tblRespuestasPreguntas] with (nolock)
	where IDCatPregunta = @IDCatPregunta
GO
