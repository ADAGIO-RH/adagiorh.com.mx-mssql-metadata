USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Norma35.spBorrarEncuesta
(
	@IDEncuesta int,
	@IDUsuario int
)
AS
BEGIN
	
	delete  Norma35.tblRespuestasPreguntas
	where IDCatPregunta in (select IDCatPregunta from Norma35.tblCatPreguntas
							where IDCatGrupo in (select IDCatGrupo from  Norma35.tblCatGrupos
													where TipoReferencia = 2
													and IDReferencia in(select IDEncuestaEmpleado 
																		from Norma35.tblEncuestasEmpleados
																		where IDEncuesta = @IDEncuesta)))
	delete Norma35.tblCatPreguntas
	where IDCatGrupo in (select IDCatGrupo from  Norma35.tblCatGrupos
							where TipoReferencia = 2
							and IDReferencia in(select IDEncuestaEmpleado 
												from Norma35.tblEncuestasEmpleados
												where IDEncuesta = @IDEncuesta))

	delete Norma35.tblCatGrupos
	where TipoReferencia = 2
	and IDReferencia in(select IDEncuestaEmpleado 
						from Norma35.tblEncuestasEmpleados
						where IDEncuesta = @IDEncuesta)

	DELETE Norma35.tblEncuestasEmpleados
	where IDEncuesta = @IDEncuesta

	delete Norma35.tblEncuestas
	where IDEncuesta = @IDEncuesta

END
GO
