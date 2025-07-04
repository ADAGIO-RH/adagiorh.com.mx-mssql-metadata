USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Norma35].[spBuscarPreguntas](
	 @IDCatPregunta int = 0
	,@IDCatGrupo int = 0
	,@IDUsuario int 
) as
	select 
		 p.IDCatPregunta
		,p.IDCatGrupo
		,isnull(p.Pregunta,'N/A') as Pregunta
		,p.IDCatEscala
		,isnull(p.Orden,0) as Orden
	from [Norma35].[tblCatPreguntas] p with (nolock)
	where (p.IDCatPregunta = @IDCatPregunta or @IDCatPregunta = 0) and (p.IDCatGrupo = @IDCatGrupo or @IDCatGrupo = 0)
GO
