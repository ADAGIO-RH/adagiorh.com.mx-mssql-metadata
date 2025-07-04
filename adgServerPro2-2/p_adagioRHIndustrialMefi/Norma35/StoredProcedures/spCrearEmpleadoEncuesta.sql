USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author...........  : EMMANUEL CONTRERAS
-- Create date........: 
-- Last Date Modified.: 2023-02-30
-- Description........: Crea una encuesta y envia una notificación al usuario
--MODIFICACIONES
--2023-05-19	JOSE ROMAN	 REFACTORIZACIÓN
-- ========================================================
CREATE PROCEDURE [Norma35].[spCrearEmpleadoEncuesta] (
	  @IDEncuesta INT
	, @IDEmpleado INT
	, @IDUsuario  INT
	)
AS
BEGIN

	

	DECLARE @IDCatEncuesta   INT = 0
		, @CantidadPreguntas INT = 0
		, @CantidadEmpleados INT = 0
		, @IDNotificacion    INT = 0
		, @ParametrosJSON    VARCHAR(max)
		,@IDEncuestaEmpleado int;
	----------------------------------------
	--CREAR LA ENCUESTA DEL EMPLEADO
	-------------------------------------------------
	SELECT @IDCatEncuesta = IDCatEncuesta
	FROM [Norma35].[tblEncuestas]
	WHERE IDEncuesta = @IDEncuesta

	SELECT @CantidadPreguntas = count(*)
	FROM Norma35.tblCatGrupos G WITH (NOLOCK)
	JOIN Norma35.tblCatPreguntas p WITH (NOLOCK) ON p.IDCatGrupo = G.IDCatGrupo
	WHERE G.TipoReferencia = 1
		AND G.IDReferencia = @IDCatEncuesta

	IF EXISTS (
			SELECT TOP 1 1
			FROM [Norma35].[tblEncuestasEmpleados] with(nolock)
			WHERE IDEncuesta = @IDEncuesta
				AND IDEmpleado = @IDEmpleado
			)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario
			, @CodigoError = '0302003'

		RETURN 0;
	END

	INSERT INTO [Norma35].[tblEncuestasEmpleados] (
		IDEncuesta
		, IDEmpleado
		, IDCatEstatus
		, FechaAsignacion
		, FechaUltimaActualizacion
		, TotalPreguntas
		, Resultado
		)
	SELECT @IDEncuesta
		, @IDEmpleado
		, 1
		, getdate()
		, getdate()
		, @CantidadPreguntas
		, 'SIN EVALUAR'

	SET @IDEncuestaEmpleado = @@IDENTITY

	

	SELECT @CantidadEmpleados = count(*)
	FROM Norma35.tblEncuestasEmpleados with(nolock)
	WHERE IDEncuesta = @IDEncuesta

	UPDATE Norma35.tblEncuestas
	SET CantidadEmpleados = @CantidadEmpleados
	WHERE IDEncuesta = @IDEncuesta

	EXEC APP.spINotificacionIniciarNorma35Empleado @IDEncuestaEmpleado = @IDEncuestaEmpleado, @IDUsuario = @IDUsuario
	
END
GO
