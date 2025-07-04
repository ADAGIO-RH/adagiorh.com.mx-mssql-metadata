USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBorrarEncuestaEmpleado]
(
	@IDEncuestaEmpleado int,
	@IDUsuario int
)
AS
BEGIN

DECLARE @CantidadEmpleados int,
		@IDEncuesta int

		select @IDEncuesta = IDEncuesta from Norma35.tblEncuestasEmpleados where IDEncuestaEmpleado = @IDEncuestaEmpleado

	
	delete  Norma35.tblRespuestasPreguntas
	where IDCatPregunta in (select IDCatPregunta from Norma35.tblCatPreguntas
							where IDCatGrupo in (select IDCatGrupo from Norma35.tblCatGrupos
												where TipoReferencia = 2
												and IDReferencia = @IDEncuestaEmpleado))
	delete Norma35.tblCatPreguntas
	where IDCatGrupo in (select IDCatGrupo from Norma35.tblCatGrupos
						where TipoReferencia = 2
						and IDReferencia = @IDEncuestaEmpleado)

	delete Norma35.tblCatGrupos
	where TipoReferencia = 2
	and IDReferencia = @IDEncuestaEmpleado

	DELETE Norma35.tblEncuestasEmpleados
	where IDEncuestaEmpleado = @IDEncuestaEmpleado


	select @CantidadEmpleados = count(*)
	from Norma35.tblEncuestasEmpleados
	where IDEncuesta = @IDEncuesta

	update Norma35.tblEncuestas
		set CantidadEmpleados = @CantidadEmpleados
	where IDEncuesta = @IDEncuesta 

END
GO
