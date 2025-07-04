USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spFinalizarEncuestaEmpleado](
	@IDEncuestaEmpleado int,
	@TotalPreguntas int = 0
)
AS
BEGIN
	DECLARE 
		@IDCatEncuesta int ,
		@IDEncuesta int,
		@Resultado Varchar(100),
		@RequiereAtencion varchar(100) = '',
		@EncTraGrupo1 int,
		@EncTraGrupo2 int,
		@EncTraGrupo3 int,
		@EncTraGrupo4 int,
		@TotalPreguntasExtras int = 0
	;
	
	select 
		@IDCatEncuesta = E.IDCatEncuesta 
	FROM Norma35.tblEncuestasEmpleados EE with (nolock)
		inner join Norma35.tblEncuestas E with (nolock) on E.IDEncuesta = EE.IDEncuesta
	where IDEncuestaEmpleado = @IDEncuestaEmpleado

	select 
		@TotalPreguntas = count(p.IDCatPregunta)
	FROM Norma35.tblEncuestasEmpleados EE with (nolock)
		inner join Norma35.tblCatGrupos g on g.IDReferencia = EE.IDEncuestaEmpleado and g.TipoReferencia = 2
		inner join Norma35.tblCatPreguntas p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
	where EE.IDEncuestaEmpleado = @IDEncuestaEmpleado

	select @TotalPreguntasExtras = COUNT(IDPreguntaExtraEncuesta)
	from Norma35.tblPreguntasExtrasEncuestas
	where IDEncuesta = @IDCatEncuesta

	IF(@IDCatEncuesta = 1)
	BEGIN
		select 
			@Resultado = 
				CASE WHEN SUM(rp.ValorFinal) > 0 THEN 'CON ACONTECIMIENTO'
					ELSE 'SIN ACONTECIMIENTO'
				END
		from Norma35.tblEncuestasEmpleados EE with (nolock)
			inner join Norma35.tblEncuestas E with (nolock) on EE.IDEncuesta = E.IDEncuesta
			inner join Norma35.tblCatGrupos G with (nolock) on G.TipoReferencia = 2 and G.IDReferencia = EE.IDEncuestaEmpleado
			inner join Norma35.tblCatPreguntas p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
			inner join Norma35.tblCatEscalas esc with (nolock) on esc.IDCatEscala = p.IDCatEscala
			inner join Norma35.tblCatDetalleEscala DetEscala with (nolock) on DetEscala.IDCatEscala = esc.IDCatEscala
			left join Norma35.tblRespuestasPreguntas rp with (nolock) on p.IDCatPregunta = rp.IDCatPregunta
		where ee.IDEncuestaEmpleado = @IDEncuestaEmpleado

		select @EncTraGrupo1 = sum(isnull(rp.ValorFinal,0)) 
		from Norma35.tblCatGrupos G with (nolock)
			inner join Norma35.tblCatPreguntas p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
			left join Norma35.tblRespuestasPreguntas rp with (nolock) on p.IDCatPregunta = rp.IDCatPregunta
		where G.TipoReferencia = 2 
			and G.IDReferencia = @IDEncuestaEmpleado
			and G.Orden = 0

		select @EncTraGrupo2 = sum(isnull(rp.ValorFinal,0)) 
		from Norma35.tblCatGrupos G with (nolock)
			inner join Norma35.tblCatPreguntas p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
			left join Norma35.tblRespuestasPreguntas rp with (nolock) on p.IDCatPregunta = rp.IDCatPregunta
		where G.TipoReferencia = 2 
			and G.IDReferencia = @IDEncuestaEmpleado
			and G.Orden = 1

		select @EncTraGrupo3 = sum(isnull(rp.ValorFinal,0)) 
		from Norma35.tblCatGrupos G with (nolock)
			inner join Norma35.tblCatPreguntas p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
			left join Norma35.tblRespuestasPreguntas rp with (nolock) on p.IDCatPregunta = rp.IDCatPregunta
		where G.TipoReferencia = 2 
			and G.IDReferencia = @IDEncuestaEmpleado
			and G.Orden = 2

		select @EncTraGrupo4 = sum(isnull(rp.ValorFinal,0)) 
		from Norma35.tblCatGrupos G with (nolock)
			inner join Norma35.tblCatPreguntas p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
			left join Norma35.tblRespuestasPreguntas rp with (nolock) on p.IDCatPregunta = rp.IDCatPregunta
		where G.TipoReferencia = 2 
			and G.IDReferencia = @IDEncuestaEmpleado
			and G.Orden = 3

		select @RequiereAtencion = CASE WHEN @EncTraGrupo1 >= 1 and @EncTraGrupo2 >= 1 THEN 'SI'
										WHEN @EncTraGrupo1 >= 1 and @EncTraGrupo3 >= 3 THEN 'SI'
										WHEN @EncTraGrupo1 >= 1 and @EncTraGrupo4 >= 2 THEN 'SI'
										ELSE 'NO'
										END
	END
	ELSE IF(@IDCatEncuesta = 2)
	BEGIN
		select 
			@Resultado =	
				CASE WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 0 AND 19 THEN 'NULO'
					WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 20 AND 44 THEN 'BAJO'	
					WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 45 AND 69 THEN 'MEDIO'	
					WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 70 AND 89 THEN 'ALTO'	
					WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 90 AND 99999999 THEN 'MUY ALTO'	
				ELSE 'SIN ACONTECIMIENTO'
				END
		from Norma35.tblEncuestasEmpleados EE with (nolock)
			inner join Norma35.tblEncuestas E with (nolock) on EE.IDEncuesta = E.IDEncuesta
			inner join Norma35.tblCatGrupos G with (nolock) on G.TipoReferencia = 2 and G.IDReferencia = EE.IDEncuestaEmpleado
			inner join Norma35.tblCatPreguntas p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
			--inner join Norma35.tblCatEscalas esc on esc.IDCatEscala = p.IDCatEscala
			--inner join Norma35.tblCatDetalleEscala DetEscala on DetEscala.IDCatEscala = esc.IDCatEscala
			left join Norma35.tblRespuestasPreguntas rp with (nolock) on p.IDCatPregunta = rp.IDCatPregunta
		where ee.IDEncuestaEmpleado = @IDEncuestaEmpleado
	END
	ELSE IF(@IDCatEncuesta = 3)
	BEGIN
		select 
			 @Resultado =	
				CASE WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 0 AND 49 THEN 'NULO'
					WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 50 AND 74 THEN 'BAJO'	
					WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 75 AND 98 THEN 'MEDIO'	
					WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 99 AND 139 THEN 'ALTO'	
					WHEN SUM(ISNULL(rp.ValorFinal,0)) Between 140 AND 99999999 THEN 'MUY ALTO'	
				ELSE 'SIN ACONTECIMIENTO'
				END
		from Norma35.tblEncuestasEmpleados EE with (nolock)
			inner join Norma35.tblEncuestas E with (nolock) on EE.IDEncuesta = E.IDEncuesta
			inner join Norma35.tblCatGrupos G with (nolock) on G.TipoReferencia = 2 and G.IDReferencia = EE.IDEncuestaEmpleado
			inner join Norma35.tblCatPreguntas p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
			--inner join Norma35.tblCatEscalas esc
			--	on esc.IDCatEscala = p.IDCatEscala
			--inner join Norma35.tblCatDetalleEscala DetEscala
			--	on DetEscala.IDCatEscala = esc.IDCatEscala
			left join Norma35.tblRespuestasPreguntas rp with (nolock) on p.IDCatPregunta = rp.IDCatPregunta
		where ee.IDEncuestaEmpleado = @IDEncuestaEmpleado
	END

	update Norma35.tblEncuestasEmpleados 
		set 
			IDCatEstatus = 3
			, Resultado = @Resultado
			, RequiereAtencion = @RequiereAtencion
			, TotalPreguntas = case when @TotalPreguntas > 0 then @TotalPreguntas else TotalPreguntas end
	where IDEncuestaEmpleado = @IDEncuestaEmpleado

	exec [Norma35].[spActualizarPreguntasContestadasEncuestaEmpleado] @IDEncuestaEmpleado=@IDEncuestaEmpleado
END
GO
