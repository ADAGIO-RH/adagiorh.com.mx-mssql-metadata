USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spBuscarValorTotalPrueba](
	@IDCuestionarioEmpleado int
)as

	declare
		@ValorTotalPrueba decimal(18,2) = 0.00,
		@IDPregunta int = 0,
		@IDTipoPregunta int = 0,
		@IDCuestionario int
	;

	select @IDCuestionario = IDCuestionario 
	from Salud.tblCuestionarios with (nolock) 
	where IDReferencia = @IDCuestionarioEmpleado and TipoReferencia = 2

	if OBJECT_ID('tempdb..#tempPreguntas') is not null drop table #tempPreguntas	
	
	select 
		@ValorTotalPrueba = sum(s.ValorMaximo)
	from Salud.tblSecciones s with (nolock)
	where s.IDCuestionario = @IDCuestionario


	select 
		'' as Resultado
		,100.00 - 61.19 as Total
	UNION
	select 
		'Resultados obtenido' as Resultado
		,cast((sum(rp.ValorFinal) * 100.00 ) / @ValorTotalPrueba as decimal(18,2)) as Total
	from Salud.tblSecciones s with (nolock)
		join Salud.tblPreguntas p with (nolock) on s.IDSeccion = p.IDSeccion
		left join salud.tblRespuestasPreguntas rp with (nolock) on rp.IDPregunta = p.IDPregunta
	where s.IDCuestionario = @IDCuestionario
GO
