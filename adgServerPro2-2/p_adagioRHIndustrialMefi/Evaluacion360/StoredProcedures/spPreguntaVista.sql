USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Evaluacion360].[spPreguntaVista](
	@IDPregunta INT = 0,
	@IDGrupo INT = 0,
	@IDUsuario INT
) AS
	
	-- GRUPO VISTO
	IF(@IDGrupo > 0 AND @IDPregunta = 0)
		BEGIN
			UPDATE [Evaluacion360].[tblCatPreguntas]
			SET Vista = 1
			WHERE IDGrupo = @IDGrupo
		END
	
	-- PREGUNTA VISTA
	IF(@IDPregunta > 0 AND @IDGrupo = 0)
		BEGIN
			UPDATE [Evaluacion360].[tblCatPreguntas]
			SET Vista = 1
			WHERE IDPregunta = @IDPregunta
		END
GO
