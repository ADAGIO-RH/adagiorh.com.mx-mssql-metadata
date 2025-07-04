USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Salud].[spBuscarPosiblesRespuestasPreguntas](
	@IDPregunta int
) as
	
	select IDPosibleRespuesta
		,IDPregunta
		,OpcionRespuesta
		,isnull(Valor,0) Valor
	from Salud.tblPosiblesRespuestasPreguntas
	where IDPregunta = @IDPregunta
	Order by IDPosibleRespuesta asc
GO
