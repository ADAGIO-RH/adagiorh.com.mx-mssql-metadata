USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spReporteGeneralFRPGraficaPorCategoriaBKMAL] --22
(
	@IDEncuesta int
)
AS
BEGIN
	Select C.Descripcion as Categoria,
		   SUM(RP.ValorFinal) as ValorFinal,
		   CCE.CalificacionLiteral,
		   CCE.Inicio,
		   CCE.Fin ,
		   CASE WHEN CCE.CalificacionLiteral = 'Nulo' THEN '#5F77FF'
								WHEN CCE.CalificacionLiteral = 'Bajo' THEN '#00C0C0'
								WHEN CCE.CalificacionLiteral = 'Medio' THEN '#FFFF00'
								WHEN CCE.CalificacionLiteral = 'Alto' THEN '#FFC000'
								WHEN CCE.CalificacionLiteral = 'Muy alto' THEN '#FF0000'
								ELSE '#5F77FF'
								END as Color,
		CASE WHEN CCE.CalificacionLiteral = 'Nulo' THEN 1
								WHEN CCE.CalificacionLiteral = 'Bajo' THEN 2
								WHEN CCE.CalificacionLiteral = 'Medio' THEN 3
								WHEN CCE.CalificacionLiteral = 'Alto' THEN 4
								WHEN CCE.CalificacionLiteral = 'Muy alto' THEN 5
								ELSE 1
								END as ValorLiteral
	from Norma35.tblEncuestasEmpleados EE 
		inner join Norma35.tblEncuestas E
			on EE.IDEncuesta = E.IDEncuesta
		inner join Norma35.tblCatGrupos G
			on G.TipoReferencia = 2 
				and G.IDReferencia = EE.IDEncuestaEmpleado
		inner join Norma35.tblCatPreguntas P
			on P.IDCatGrupo = G.IDCatGrupo
		inner join Norma35.tblcatCategorias C
			on C.IDCategoria = P.IDCategoria
		Inner join Norma35.tblRespuestasPreguntas RP
			on RP.IDCatPregunta = P.IDCatPregunta
		inner join  Norma35.tblCalificacionCategoriaEncuestas CCE
			on CCE.IDCatEncuesta = E.IDCatEncuesta
			and CCE.IDCategoria = P.IDCategoria
	where EE.IDEncuesta = @IDEncuesta
	Group by  C.Descripcion ,CCE.CalificacionLiteral,
		   CCE.Inicio,
		   CCE.Fin 
	HAVING SUM(RP.ValorFinal) Between CCE.Inicio and    CCE.Fin
	ORDER BY C.Descripcion,CCE.Inicio




END
GO
