USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	IDCatEstatus	Descripcion
	------------ | --------------
	1            | Activa
	2            | Incompleta
	3            | Completada
	4            | Cancelada
	5            | Expirada
*/
create   proc [Norma35].[spActualizarPreguntasContestadasEncuestaEmpleado](
	@IDEncuestaEmpleado int = 11104
) as
	declare 
		@TotalPreguntasContestadas int = 0,
		@TotalPreguntasExtrasContestadas int = 0,
		@IDCatEstatus int,
		@ID_CATESTATUS_ENCUESTA_EMPLEADO_ACTIVA int = 1,
		@IDEncuesta int
	;

	select 
		@IDCatEstatus = IDCatEstatus,
		@IDEncuesta = IDEncuesta
	from Norma35.tblEncuestasEmpleados 
	where IDEncuestaEmpleado = @IDEncuestaEmpleado

	if (@IDCatEstatus != @ID_CATESTATUS_ENCUESTA_EMPLEADO_ACTIVA)
	begin
		update [Norma35].[tblEncuestasEmpleados]
			set TotalPreguntas = (select COUNT(*)
									from [Norma35].[tblCatGrupos] cg with (nolock)
										join [Norma35].[tblCatPreguntas] p on p.IDCatGrupo = cg.IDCatGrupo
										join [Norma35].[tblRespuestasPreguntas] rp on rp.IDCatPregunta = p.IDCatPregunta
 									where cg.TipoReferencia = 2 and cg.IDReferencia = @IDEncuestaEmpleado) 
									+
								(select COUNT(*)
									from [Norma35].[tblPreguntasExtrasEncuestas]
									where IDEncuesta = @IDEncuesta)
		where IDEncuestaEmpleado = @IDEncuestaEmpleado
	end

	select @TotalPreguntasContestadas = COUNT(*) 
	from [Norma35].[tblCatGrupos] g with (nolock)
		join [Norma35].[tblCatPreguntas] p with (nolock) on p.IDCatGrupo = g.IDCatGrupo
		join [Norma35].[tblRespuestasPreguntas] rp with (nolock) on rp.IDCatPregunta = p.IDCatPregunta
	where g.TipoReferencia = 2 and g.IDReferencia = @IDEncuestaEmpleado

	select @TotalPreguntasExtrasContestadas = COUNT(*)
	from [Norma35].[tblPreguntasExtrasEncuestas] pee with (nolock)
		join [Norma35].[tblEncuestasEmpleados] ee with (nolock) on ee.IDEncuesta = pee.IDEncuesta
		join [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados] rpeee with (nolock) on ee.IDEncuestaEmpleado = rpeee.IDEncuestaEmpleado 
			and rpeee.IDPreguntaExtraEncuesta = pee.IDPreguntaExtraEncuesta
	where (ee.IDEncuestaEmpleado = @IDEncuestaEmpleado) and ISNULL(rpeee.Respuesta, '') != ''

	update [Norma35].[tblEncuestasEmpleados]
		set TotalPreguntasContestadas = ISNULL(@TotalPreguntasContestadas, 0) + ISNULL(@TotalPreguntasExtrasContestadas, 0)
	where IDEncuestaEmpleado = @IDEncuestaEmpleado
GO
