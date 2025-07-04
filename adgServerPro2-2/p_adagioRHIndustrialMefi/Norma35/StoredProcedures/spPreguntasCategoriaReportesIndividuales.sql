USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Norma35.spPreguntasCategoriaReportesIndividuales --51
(
	@IDEncuestaEmpleado int
)
AS
BEGIN


	select  
			C.Descripcion as Categoria
			,CCE.CalificacionLiteral  as Resultado
			--,SUM(rp.ValorFinal)
			--,CCE.Inicio
			--,CCE.Fin
			from Norma35.tblEncuestasEmpleados EE
				inner join Norma35.tblEncuestas E
					on EE.IDEncuesta = E.IDEncuesta
				inner join Norma35.tblCatGrupos G
					on G.TipoReferencia = 2 and G.IDReferencia = EE.IDEncuestaEmpleado
				inner join Norma35.tblCatPreguntas p
					on p.IDCatGrupo = g.IDCatGrupo
				inner join Norma35.tblcatCategorias C
					on P.IDCategoria = C.IDCategoria
				Inner join Norma35.tblCalificacionCategoriaEncuestas CCE
					on C.IDCategoria = CCE.IDCategoria
					and CCE.IDCatEncuesta = E.IDCatEncuesta
				--left join Norma35.tblCatEscalas esc
				--	on esc.IDCatEscala = p.IDCatEscala
				--left join Norma35.tblCatDetalleEscala DetEscala
				--	on DetEscala.IDCatEscala = esc.IDCatEscala
				inner join Norma35.tblRespuestasPreguntas rp
					on p.IDCatPregunta = rp.IDCatPregunta
		
				
			where ee.IDEncuestaEmpleado = @IDEncuestaEmpleado
			Group by C.Descripcion, CCE.Inicio, CCE.Fin,CCE.CalificacionLiteral
			Having SUM(rp.ValorFinal) Between CCE.Inicio and CCE.Fin
			ORDER BY C.Descripcion
END
GO
