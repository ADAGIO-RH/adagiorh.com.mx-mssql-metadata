USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Evaluacion360].[spUCategoriaPregunta](
	@IDPregunta int
	,@IDCategoriaPregunta int
	,@IDUsuario int
) as
	update [Evaluacion360].[tblCatPreguntas]
	set IDCategoriaPregunta = @IDCategoriaPregunta
	where IDPregunta = @IDPregunta
GO
