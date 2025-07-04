USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Emnmanuel Contreras
-- Create date: 2023-01-20
-- Description: Sp para horarios empleados Map
-- =============================================
CREATE PROCEDURE [Asistencia].[spUIHorariosEmpleadoMap] (
	@dtImportacion [Asistencia].[dtHorariosImportacion] READONLY
	,@IDUsuario INT
	)
AS
BEGIN
	DECLARE @tempMessages AS TABLE (
		ID INT
		,[Message] VARCHAR(500)
		,Valid BIT
		)
	DECLARE @IDIdioma VARCHAR(225);

	SELECT @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-', ''))

	INSERT @tempMessages (
		ID
		,[Message]
		,Valid
		)
	SELECT [IDMensajeTipo]
		,[Mensaje]
		,[Valid]
	FROM [RH].[tblMensajesMap]
	WHERE [MensajeTipo] = 'HorariosMap'
	ORDER BY [IDMensajeTipo];

	SELECT info.*
		,(
			SELECT m.[Message] AS Message
				,CAST(m.Valid AS BIT) AS Valid
			FROM @tempMessages m
			WHERE ID IN (
					SELECT ITEM
					FROM app.split(info.IDMensaje, ',')
					)
			FOR JSON PATH
			) AS Msg
		,CAST(CASE 
				WHEN EXISTS (
						(
							SELECT m.[Valid] AS Message
							FROM @tempMessages m
							WHERE ID IN (
									SELECT ITEM
									FROM app.split(info.IDMensaje, ',')
									)
								AND Valid = 0
							)
						)
					THEN 0
				ELSE 1
				END AS BIT) AS Valid
	FROM (
		SELECT ROW_NUMBER() OVER (
				ORDER BY e.ClaveEmpleado
					,FechaInicio ASC
				) AS RN
			,isnull(em.IDEmpleado, 0) AS [IDEmpleado]
			,E.[ClaveEmpleado]
			,isnull(em.NOMBRECOMPLETO, '') AS [NombreCompleto]
			,isnull((
					SELECT TOP 1 IDHorario
					FROM Asistencia.tblCatHorarios
					WHERE Codigo = E.[Horario]
					), 0) AS [IDHorario]
			,E.Horario AS CodigoHorario
			,isnull((
					SELECT TOP 1 Descripcion
					FROM Asistencia.tblCatHorarios
					WHERE Codigo = E.[Horario]
					), '') AS [Horario]
			,cast(isnull(E.[FechaInicio], '9999-12-31') AS DATE) AS [FechaInicio]
			,cast(isnull(E.[FechaFin], '9999-12-31') AS DATE) AS [FechaFin]
			,IDMensaje = 
				IIF(EXISTS ( SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados WHERE ClaveEmpleado = E.[ClaveEmpleado]), '', '2,') + 
				IIF(EXISTS (SELECT TOP 1 1 FROM [Asistencia].[tblCatHorarios] WHERE Codigo = E.Horario), '', '3,') + 
				CASE 
					WHEN TRY_CONVERT(DATE, E.FechaInicio) IS NULL
						THEN '4,'
					ELSE ''
				END + 
				CASE 
					WHEN TRY_CONVERT(DATE, E.FechaFin) IS NULL
						THEN '5,'
					ELSE ''
				END
				+ IIF(EXISTS (
					SELECT TOP 1 1
					FROM Seguridad.tblDetalleFiltrosEmpleadosUsuarios sE
					WHERE sE.IDEmpleado = em.IDEmpleado
						AND sE.IDusuario = @IDUsuario
					), '', '6,')
		FROM @dtImportacion E
		LEFT JOIN RH.tblEmpleadosMaster em ON E.ClaveEmpleado = em.ClaveEmpleado
		WHERE isnull(E.ClaveEmpleado, '') <> ''
		) info
	ORDER BY info.ClaveEmpleado
END
GO
