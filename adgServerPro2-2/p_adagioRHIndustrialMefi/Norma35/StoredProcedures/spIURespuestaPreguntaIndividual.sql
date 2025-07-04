USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Norma35].[spIURespuestaPreguntaIndividual](
	@IDRespuestaPregunta int = 0,
	@IDCatPregunta int,
	@Respuesta varchar(max)
) as
	declare 
		@ValorFinal decimal(18,2),
		@IDEncuestaEmpleado int

	select @IDEncuestaEmpleado = g.IDReferencia
	from [Norma35].[tblCatPreguntas] p with (nolock)
		join [Norma35].[tblCatGrupos] g with (nolock) on g.IDCatGrupo = p.IDCatGrupo
	where IDCatPregunta = @IDCatPregunta

	select top 1 @ValorFinal = Valor
	from [Norma35].[tblCatDetalleEscala]
	where IDCatDetalleEscala = CAST(@Respuesta as Int)

	if ((isnull(@IDRespuestaPregunta, 0) = 0) and 
			not exists (select top 1 1 
					from [Norma35].[tblRespuestasPreguntas] 
					where IDCatPregunta = @IDCatPregunta))
	begin
		insert [Norma35].[tblRespuestasPreguntas](IDCatPregunta,Respuesta,FechaRespuesta,ValorFinal)
		select @IDCatPregunta,@Respuesta,GETDATE(),@ValorFinal
	end else
	begin
		if (isnull(@IDRespuestaPregunta, 0) = 0) 
		begin
			select top 1 @IDRespuestaPregunta = IDRespuestaPregunta 
			from [Norma35].[tblRespuestasPreguntas] 
			where IDCatPregunta = @IDCatPregunta
		end

		update [Norma35].[tblRespuestasPreguntas]
			set Respuesta = @Respuesta,
				FechaRespuesta = GETDATE(),
				ValorFinal = @ValorFinal
		where IDRespuestaPregunta = @IDRespuestaPregunta
	end;

	exec [Norma35].[spActualizarPreguntasContestadasEncuestaEmpleado] @IDEncuestaEmpleado=@IDEncuestaEmpleado

	--update [Norma35].[tblEncuestasEmpleados]
	--	set TotalPreguntasContestadas = (select COUNT(*) 
	--									from [Norma35].[tblCatGrupos] g with (nolock)
	--										join [Norma35].[tblCatPreguntas] p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
	--										join [Norma35].[tblRespuestasPreguntas] rp with (nolock) on rp.IDCatPregunta = p.IDCatPregunta
	--									where g.TipoReferencia = 2 and g.IDReferencia = @IDEncuestaEmpleado)
	--where IDEncuestaEmpleado = @IDEncuestaEmpleado
GO
