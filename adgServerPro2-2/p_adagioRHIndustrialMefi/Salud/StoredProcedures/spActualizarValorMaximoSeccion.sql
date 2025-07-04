USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Salud.spActualizarValorMaximoSeccion(
	@IDSeccion int
) as
	declare
		@ValorTotalPrueba decimal(18,2) = 0.00,
		@IDPregunta int = 0,
		@IDTipoPregunta int = 0
	;

	if OBJECT_ID('tempdb..#tempPreguntas') is not null drop table #tempPreguntas	

	select p.IDPregunta, p.IDTipoPregunta
	INTO #tempPreguntas
	from Salud.tblSecciones s with (nolock)
		join Salud.tblPreguntas p with (nolock) on s.IDSeccion = p.IDSeccion
	where s.IDSeccion = @IDSeccion

	select @IDPregunta = MIN(IDPregunta) from #tempPreguntas
	while exists(select top 1 1 from #tempPreguntas where IDPregunta >= @IDPregunta) 
	begin
		select @IDTipoPregunta = IDTipoPregunta from #tempPreguntas where IDPregunta = @IDPregunta

		if (@IDTipoPregunta = 1)
		begin
			set @ValorTotalPrueba = @ValorTotalPrueba + (select MAX(Valor) from Salud.tblPosiblesRespuestasPreguntas with (nolock) where IDPregunta = @IDPregunta)
		end else 
		begin
			set @ValorTotalPrueba = @ValorTotalPrueba + (select sum(Valor) from Salud.tblPosiblesRespuestasPreguntas with (nolock) where IDPregunta = @IDPregunta)
		end
		select @IDPregunta = MIN(IDPregunta) from #tempPreguntas where IDPregunta > @IDPregunta
	end;

	update Salud.tblSecciones
		set ValorMaximo = @ValorTotalPrueba
	where IDSeccion = @IDSeccion
GO
