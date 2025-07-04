USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Salud].[spBuscarValorTotalPrueba](
	@IDCuestionario int
)as

	declare
		@ValorTotalPrueba decimal(18,2) = 0.00,
		@IDPregunta int = 0,
		@IDTipoPregunta int = 0
	;
	
	select 
		@ValorTotalPrueba = sum(s.ValorMaximo)
	from Salud.tblSecciones s with (nolock)
	where s.IDCuestionario = @IDCuestionario

	select 
		isnull(sum(rp.ValorFinal),0) as Total,
		@ValorTotalPrueba as ValorTotalPrueba
	from Salud.tblSecciones s with (nolock)
		join Salud.tblPreguntas p with (nolock) on s.IDSeccion = p.IDSeccion
		left join salud.tblRespuestasPreguntas rp with (nolock) on rp.IDPregunta = p.IDPregunta
	where s.IDCuestionario = @IDCuestionario
GO
