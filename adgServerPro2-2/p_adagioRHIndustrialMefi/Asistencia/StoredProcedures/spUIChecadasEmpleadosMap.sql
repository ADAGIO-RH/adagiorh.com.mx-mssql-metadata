USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Emmanuel Contreras
-- Create date: 2023-01-24
-- Description: SP para importar Map de Checadas Empleados
-- =============================================
CREATE PROCEDURE [Asistencia].[spUIChecadasEmpleadosMap] (
	@dtImportacion [Asistencia].[dtChecadasImportacion] READONLY
	,@IDUsuario INT
	)
AS
BEGIN
	DECLARE @tempMessages AS TABLE (
		ID INT
		,[Message] VARCHAR(500)
		,Valid BIT
		)

	INSERT @tempMessages (
		ID
		,[Message]
		,Valid
		)
	SELECT [IDMensajeTipo]
		,[Mensaje]
		,[Valid]
	FROM [RH].[tblMensajesMap]
	WHERE [MensajeTipo] = 'ChecadasMap'
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
				ORDER BY em.ClaveEmpleado
					,Fecha ASC
				) AS RN
			,isnull(em.IDEmpleado, 0) AS [IDEmpleado]
			,E.[ClaveEmpleado]
			,isnull(em.NOMBRECOMPLETO, '') AS [NombreCompleto]
			,cast(isnull(E.[Fecha], '9999-12-31') AS VARCHAR(20)) + ' ' + cast(isnull(E.[Hora], '00:00:00') AS VARCHAR(20)) AS [Fecha]
			,IDMensaje = IIF(EXISTS (
					SELECT TOP 1 IDEmpleado
					FROM RH.tblEmpleados
					WHERE ClaveEmpleado = E.[ClaveEmpleado]
					), '', '2,') + CASE 
				WHEN TRY_CONVERT(DATE, E.Fecha) IS NULL
					THEN '3,'
				ELSE ''
				END + CASE 
				WHEN TRY_CONVERT(TIME, E.[Hora]) IS NULL
					THEN '4,'
				ELSE ''
				END
				+ IIF(EXISTS (
					SELECT TOP 1 1
					FROM Seguridad.tblDetalleFiltrosEmpleadosUsuarios sE
					WHERE sE.IDEmpleado = em.IDEmpleado
						AND sE.IDusuario = @IDUsuario
					), '', '5,')
		FROM @dtImportacion E
		LEFT JOIN RH.tblEmpleadosMaster em ON e.ClaveEmpleado = em.ClaveEmpleado
		LEFT JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe ON em.IDEmpleado = dfe.IDEmpleado
		AND dfe.IDUsuario = @IDUsuario
		WHERE isnull(E.ClaveEmpleado, '') <> ''
		) info
	ORDER BY info.ClaveEmpleado
END
GO
