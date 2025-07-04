USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Emmanuel Contreras
-- Create date: 2023-01-20
-- Description: Importación masiva para incidencias empleados
-- =============================================
/****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-09-12		Andrea Zainos		Se agrega validacion para que arroje un error cuando el IDIncidencia  contenga
                                    el campo TiempoIncidencia en falso y se este tratando de insertar el tiempo
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spIUImportacionIncidenciasMap] (
	@dtIncidencias [Asistencia].[dtIncidenciasAusentismosImportacion] READONLY
	, @IDUsuario INT
	)
AS
BEGIN
	DECLARE @tempMessages AS TABLE (
		ID INT
		, [Message] VARCHAR(500)
		, Valid BIT
		)
	DECLARE @IDIdioma VARCHAR(225);

	SELECT @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-', ''))

	IF OBJECT_ID('tempdb..#TempIncidencias') IS NOT NULL
		DROP TABLE #TempIncidencias

	SELECT ID
	INTO #TempIncidencias
	FROM Seguridad.tblFiltrosUsuarios WITH (NOLOCK)
	WHERE IDUsuario = @IDUsuario
		AND Filtro = 'IncidenciasAusentismos'

	INSERT @tempMessages (
		ID
		, [Message]
		, Valid
		)
	SELECT [IDMensajeTipo]
		, [Mensaje]
		, [Valid]
	FROM [RH].[tblMensajesMap]
	WHERE [MensajeTipo] = 'IncidenciasMap'
	ORDER BY [IDMensajeTipo];

	SELECT info.*
		, (
			SELECT m.[Message] AS Message
				, CAST(m.Valid AS BIT) AS Valid
			FROM @tempMessages m
			WHERE ID IN (
					SELECT ITEM
					FROM app.split(info.IDMensaje, ',')
					)
			FOR JSON PATH
			) AS Msg
		, CAST(CASE 
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
		SELECT isnull((
					SELECT TOP 1 IDEmpleado
					FROM RH.tblEmpleados
					WHERE ClaveEmpleado = em.ClaveEmpleado
					), 0) AS [IDEmpleado]
			, I.[ClaveEmpleado]
			, isnull(em.NOMBRECOMPLETO, '') AS [NombreCompleto]
			, I.IDIncidencia
            , I.Tiempo
			, isnull((
					SELECT TOP 1 JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-', '')), 'Descripcion')) AS Descripcion
					FROM Asistencia.tblCatIncidencias
					WHERE IDIncidencia = I.[IDIncidencia]
					), '') AS [Incidencia]
			, FORMAT(cast(isnull(I.[Fecha], '9999-12-31') AS DATE), 'dd/MM/yyyy') AS [Fecha]
			, IDMensaje = IIF(EXISTS (SELECT TOP 1 IDEmpleado FROM RH.tblEmpleados WHERE ClaveEmpleado = I.[ClaveEmpleado]), '', '2,') + 
                    IIF(EXISTS (SELECT TOP 1 1 FROM [Asistencia].[tblCatIncidencias] WHERE IDIncidencia = I.IDIncidencia), '', '3,') + 
                    CASE 
                        WHEN TRY_CONVERT(DATE, I.Fecha) IS NULL 
                        THEN '4,' ELSE ''
                    END 
				+ IIF(EXISTS (SELECT TOP 1 1 FROM Seguridad.tblDetalleFiltrosEmpleadosUsuarios sE WHERE sE.IDEmpleado = em.IDEmpleado AND sE.IDusuario = @IDUsuario), '', '5,')
                + IIF(I.IDIncidencia='I','6,','')		
                + IIF(EXISTS ( SELECT TOP 1 1  FROM [Asistencia].[tblCatIncidencias] CI WHERE CI.IDIncidencia = I.IDIncidencia  AND CI.TiempoIncidencia = 0 ) AND I.Tiempo > '00:00:00.000', '7,', '' ) 
		FROM @dtIncidencias I
		LEFT JOIN RH.tblEmpleadosMaster em ON I.ClaveEmpleado = em.ClaveEmpleado
		LEFT JOIN #TempIncidencias tempInc ON I.IDIncidencia = tempInc.ID
		WHERE isnull(I.ClaveEmpleado, '') <> ''
		) info
	ORDER BY info.ClaveEmpleado
END
GO
