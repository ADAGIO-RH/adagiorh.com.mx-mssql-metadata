USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create  proc [Norma35].[spBorrarRespuestaPreguntasPorGrupo](
	@IDCatGrupo int
) as
	delete rp
	from [Norma35].[tblCatGrupos] g
		join [Norma35].[tblCatPreguntas] p on p.IDCatGrupo = g.IDCatGrupo
		join [Norma35].[tblRespuestasPreguntas] rp on rp.IDCatPregunta = p.IDCatPregunta
	where g.IDCatGrupo = @IDCatGrupo
GO
