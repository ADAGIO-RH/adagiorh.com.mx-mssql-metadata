USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Norma35].[spBorrarPreguntaExtraEncuenta](
	@IDPreguntaExtraEncuesta int,
	@IDUsuario int
) as
begin
	declare 
		@ResponseErrorMsg varchar(max),
		@PreguntaExistente varchar(250)
	;
	
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

	exec [Norma35].[spBuscarPreguntasExtrasEncuestas] 
		@IDPreguntaExtraEncuesta=@IDPreguntaExtraEncuesta,
		@IDUsuario = @IDUsuario

	delete [Norma35].[tblPreguntasExtrasEncuestas]
	where IDPreguntaExtraEncuesta = @IDPreguntaExtraEncuesta

end
GO
