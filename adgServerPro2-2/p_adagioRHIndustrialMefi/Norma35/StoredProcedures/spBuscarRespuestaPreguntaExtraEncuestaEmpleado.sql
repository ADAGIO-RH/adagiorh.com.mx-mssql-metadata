USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Norma35].[spBuscarRespuestaPreguntaExtraEncuestaEmpleado](
	@IDRespuestaPreguntaExtraEncuestaEmpleado int = 0,
	@IDEncuestaEmpleado int,
	@IDUsuario int
) as
begin

	select 
		ISNULL(rpeee.IDRespuestaPreguntaExtraEncuestaEmpleado, 0) as IDRespuestaPreguntaExtraEncuestaEmpleado
		,ee.IDEncuestaEmpleado
		,pee.IDPreguntaExtraEncuesta
		,pee.IDEncuesta
		,pee.IDTipoPreguntaExtra
		,pee.Pregunta
		,pee.Descripcion
		,pee.Placeholder
		,pee.RespuestaLarga
		,pee.Requerida
		,rpeee.Respuesta
	from [Norma35].[tblPreguntasExtrasEncuestas] pee
		join [Norma35].[tblEncuestasEmpleados] ee 
			on ee.IDEncuesta = pee.IDEncuesta
		left join [Norma35].[tblRespuestasPreguntasExtrasEncuestasEmpleados] rpeee
			on ee.IDEncuestaEmpleado = rpeee.IDEncuestaEmpleado and rpeee.IDPreguntaExtraEncuesta = pee.IDPreguntaExtraEncuesta
	where (rpeee.IDRespuestaPreguntaExtraEncuestaEmpleado = @IDRespuestaPreguntaExtraEncuestaEmpleado or isnull(@IDRespuestaPreguntaExtraEncuestaEmpleado, 0) = 0) 
		and (ee.IDEncuestaEmpleado = @IDEncuestaEmpleado)

end
GO
