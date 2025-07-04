USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Norma35].[spIURespuestaPreguntaExtraEncuestaEmpleado](
	@IDRespuestaPreguntaExtraEncuestaEmpleado int = 0,
	@IDEncuestaEmpleado int,
	@IDPreguntaExtraEncuesta int,
	@Respuesta varchar(max),
	@IDUsuario int
) as

	if (isnull(@IDRespuestaPreguntaExtraEncuestaEmpleado, 0) = 0)
	begin
		insert [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados](IDEncuestaEmpleado, IDPreguntaExtraEncuesta, Respuesta)
		values (@IDEncuestaEmpleado, @IDPreguntaExtraEncuesta, @Respuesta)

		set @IDRespuestaPreguntaExtraEncuestaEmpleado = SCOPE_IDENTITY();
	end else
	begin
		update [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados]
			set 
				Respuesta = @Respuesta
		where IDRespuestaPreguntaExtraEncuestaEmpleado = @IDRespuestaPreguntaExtraEncuestaEmpleado
	end

	exec [Norma35].[spActualizarPreguntasContestadasEncuestaEmpleado] @IDEncuestaEmpleado=@IDEncuestaEmpleado

	exec [Norma35].[spBuscarRespuestaPreguntaExtraEncuestaEmpleado]
		@IDRespuestaPreguntaExtraEncuestaEmpleado=@IDRespuestaPreguntaExtraEncuestaEmpleado,
		@IDEncuestaEmpleado=@IDEncuestaEmpleado,
		@IDUsuario = @IDUsuario
GO
