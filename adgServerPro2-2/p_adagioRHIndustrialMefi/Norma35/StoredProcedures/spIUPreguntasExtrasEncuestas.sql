USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Norma35].[spIUPreguntasExtrasEncuestas](
	@IDPreguntaExtraEncuesta int = 0,
	@IDEncuesta int,
	@IDTipoPreguntaExtra varchar(20),
	@Pregunta varchar(250),
	@Descripcion	varchar(500),
	@Placeholder	varchar(250),
	@RespuestaLarga	bit,
	@Requerida	bit,
	@IDUsuario int
) as
	declare 
		@ResponseErrorMsg varchar(max),
		@PreguntaExistente varchar(250)
	;
	
	if (isnull(@IDPreguntaExtraEncuesta, 0) = 0)
	begin
		insert [Norma35].[tblPreguntasExtrasEncuestas](IDTipoPreguntaExtra, IDEncuesta, Pregunta, Descripcion, Placeholder, RespuestaLarga, Requerida, IDUsuarioCrea)
		values (@IDTipoPreguntaExtra, @IDEncuesta, @Pregunta, @Descripcion, @Placeholder, @RespuestaLarga, @Requerida, @IDUsuario)

		set @IDPreguntaExtraEncuesta = SCOPE_IDENTITY()
	end else
	begin
		if exists(select top 1 1
				from [Norma35].[tblPreguntasExtrasEncuestas] tee
					join [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados] rpeee 
						on tee.IDPreguntaExtraEncuesta = rpeee.IDPreguntaExtraEncuesta
				where tee.IDPreguntaExtraEncuesta = @IDPreguntaExtraEncuesta)
		begin
			select @PreguntaExistente = Pregunta
			from [Norma35].[tblPreguntasExtrasEncuestas]
			where IDPreguntaExtraEncuesta = @IDPreguntaExtraEncuesta

			set @ResponseErrorMsg = FORMATMESSAGE('La pregunta [%s] ya ha sido contestada y no puede ser modificada.', @PreguntaExistente)

			raiserror(@ResponseErrorMsg, 16, 1)
			return
		end

		update [Norma35].[tblPreguntasExtrasEncuestas]
			set
				Pregunta = @Pregunta
				, Descripcion	 = @Descripcion
				, Placeholder	 = @Placeholder
				, RespuestaLarga = @RespuestaLarga
				, Requerida		 = @Requerida
		where IDPreguntaExtraEncuesta = @IDPreguntaExtraEncuesta
	end

	exec [Norma35].[spBuscarPreguntasExtrasEncuestas] 
		@IDPreguntaExtraEncuesta=@IDPreguntaExtraEncuesta,
		@IDUsuario = @IDUsuario
GO
