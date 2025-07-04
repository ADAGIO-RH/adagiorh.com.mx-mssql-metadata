USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spPreguntasReportesIndividuales] --51
(
	@IDEncuestaEmpleado int
)
AS
BEGIN


	select G.TipoReferencia,G.IDReferencia,G.IDCatGrupo, G.Nombre as NombreGrupo, G.Nota,G.RespuestaGrupo,G.Orden, P.IDCatPregunta,P.Pregunta,DetEscala.Nombre NombreEscala,DetEscala.Valor,case when rp.Respuesta = DetEscala.IDCatDetalleEscala then 'X' else '' END Respuesta,rp.ValorFinal
			from Norma35.tblEncuestasEmpleados EE
				inner join Norma35.tblEncuestas E
					on EE.IDEncuesta = E.IDEncuesta
				inner join Norma35.tblCatGrupos G
					on G.TipoReferencia = 2 and G.IDReferencia = EE.IDEncuestaEmpleado
				inner join Norma35.tblCatPreguntas p
					on p.IDCatGrupo = g.IDCatGrupo
				left join Norma35.tblCatEscalas esc
					on esc.IDCatEscala = p.IDCatEscala
				left join Norma35.tblCatDetalleEscala DetEscala
					on DetEscala.IDCatEscala = esc.IDCatEscala
				join Norma35.tblRespuestasPreguntas rp
					on p.IDCatPregunta = rp.IDCatPregunta
			where ee.IDEncuestaEmpleado = @IDEncuestaEmpleado
		ORDER BY G.Orden ASC , P.Orden ASC
END
GO
