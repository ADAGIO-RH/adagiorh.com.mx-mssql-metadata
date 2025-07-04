USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Buscar colaboradores con el estatus de su expediente digital, hayan o no cargado el archivo.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-04-07
** Parametros		: @IDAviso			- Identificador del comunicado "aviso"
					: @IDUsuario		- Identificador del usuario
					: @PageNumber		- Numero de pagina que se esta solicitando.
					: @PageSize			- Numero de registros de la pagina.
					: @query			- Cualquier descripcion que tenga relacion con la dirección.
					: @orderByColumn	- Los registros se ordenan por la columna solicitada.
					: @orderDirection 	- Los registros pueden ser ordenados por (ASC o DESC).
** IDAzure			: #1516

** DataTypes Relacionados:
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Comunicacion].[spBuscarEmpleadosConArchivosAdjuntos](
	@IDAviso			INT = 0
	, @IDUsuario		INT = 0
	, @PageNumber		INT = 1
	, @PageSize			INT = 2147483647
	, @query			VARCHAR(100) = '""'
	, @orderByColumn	VARCHAR(50) = 'ClaveEmpleado'
	, @orderDirection	VARCHAR(4) = 'ASC'
)
AS
	BEGIN
		
		DECLARE @IsGeneral				BIT
				, @IDEstatus			INT
				, @IDTipoAviso			INT
				, @EnviarNotificacion	BIT
				, @Error				VARCHAR(MAX)
				, @COMUNICADO			INT = 2
				, @NO					BIT = 0
				;

		/* CONFIGURACION DEL AVISO */
		SELECT @IsGeneral = A.isGeneral
				, @IDEstatus = A.IDEstatus
				, @IDTipoAviso = IDTipoAviso
				, @EnviarNotificacion = EnviarNotificacion
		FROM [Comunicacion].[tblAvisos] A			
		WHERE A.IDAviso = @IDAviso;

		BEGIN TRY	
			
			BEGIN TRAN
				
				/* VALIDACIONES */

				IF (@IDAviso = 0)
					BEGIN
						EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '2700001'
						RETURN;
					END		

				IF (@IDTipoAviso <> @COMUNICADO)
					BEGIN
						EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '2700002'
						RETURN;
					END

				IF (@EnviarNotificacion = @NO)
					BEGIN
						EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '2700003'
						RETURN;
					END
					

				/* TABLA TEMPORAL */		

				DECLARE @tempResponse AS TABLE (
					IDEmpleado INT
					, ClaveEmpleado VARCHAR(20)
					, NombreCompletoEmpleado VARCHAR(255)
					, ROWNUMBER INT
				);
		
		
				/* CONFIGURACION INICIAL DEL PAGINADO */

				DECLARE @TotalPaginas		INT = 0
						, @TotalRegistros	INT
						;

				IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
				IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

				SET @query = CASE
								WHEN @query IS NULL THEN '""'
								WHEN @query = ''	THEN '""'
								WHEN @query = '""'	THEN @query
								ELSE '"' + @query + '*"' 
							 END

				SELECT	@orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'ClaveEmpleado' ELSE @orderByColumn END,
						@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END	

		
				/* OBTENEMOS REGISTROS */
				
				IF(@isGeneral = 1)
					BEGIN

						INSERT @tempResponse
						SELECT CAST(M.IDEmpleado AS INT) AS IDEmpleado
								, M.ClaveEmpleado
								, M.NOMBRECOMPLETO AS NombreCompletoEmpleado
								, ROWNUMBER = ROW_NUMBER()OVER(ORDER BY M.IDEmpleado ASC)
						FROM [RH].[tblEmpleadosMaster] M
							JOIN [Seguridad].[tblUsuarios] U ON M.IDEmpleado = U.IDEmpleado
						WHERE M.Vigente = 1 -- AND M.ClaveEmpleado = '001285'
								AND (@query = '""' OR CONTAINS(M.*, @query))
						--SELECT * FROM @tempResponse

					END
				ELSE
					BEGIN
				
						INSERT @tempResponse
						SELECT CAST(M.IDEmpleado AS INT) AS IDEmpleado
								, M.ClaveEmpleado
								, M.NOMBRECOMPLETO AS NombreCompletoEmpleado
								, ROWNUMBER = ROW_NUMBER()OVER(ORDER BY M.IDEmpleado ASC)
						FROM [RH].[tblEmpleadosMaster] M
							JOIN [Comunicacion].[tblEmpleadosAvisos] EA ON EA.IDEmpleado = M.IDEmpleado AND EA.IDAviso = @IDAviso
							JOIN [Seguridad].[tblUsuarios] U ON M.IDEmpleado = U.IDEmpleado
						WHERE M.Vigente = 1 -- AND M.ClaveEmpleado = '001285'
								AND (@query = '""' OR CONTAINS(M.*, @query))
						--SELECT * FROM @tempResponse
					END


				/* TOTAL DE PAGINAS Y REGISTROS */
				SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2)) / CAST(@PageSize AS DECIMAL(20,2))) FROM @tempResponse
				SELECT @TotalRegistros = CAST(COUNT(ClaveEmpleado) AS DECIMAL(18,2)) FROM @tempResponse


				/* RESULTADO FINAL PAGINADO */
				SELECT @IDAviso AS IDAviso
						, @IDEstatus AS IDEstatus
						, TR.IDEmpleado
						, TR.ClaveEmpleado
						, TR.NombreCompletoEmpleado,
						(
							SELECT CONF.[value]
									, CONF.[text]
									, CASE WHEN (ISNULL(ED.IDExpedienteDigitalEmpleado, 0) <> 0) THEN 1 ELSE 0 END AS isAdjunto
							FROM OPENJSON((SELECT A.FileAdjuntosExpDig FROM [Comunicacion].[tblAvisos] A WHERE A.IDAviso = @IDAviso))
							WITH (
								[value] INT '$.value'
								, [text] NVARCHAR(MAX) '$.text'
							) AS CONF
								LEFT JOIN [RH].[TblExpedienteDigitalEmpleado] ED ON CONF.[value] = ED.IDExpedienteDigital AND ED.IDEmpleado = TR.IDEmpleado
							FOR JSON PATH
						) AS FileAdjuntosExpDig				
						, TR.ROWNUMBER
						, @PageNumber AS PageNumber
						, TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
						, CAST(@TotalRegistros AS INT) AS TotalRows
				FROM @tempResponse TR
				ORDER BY
					CASE WHEN @orderByColumn = 'ClaveEmpleado'	and @orderDirection = 'asc'	THEN TR.ClaveEmpleado END,
					CASE WHEN @orderByColumn = 'ClaveEmpleado'	and @orderDirection = 'desc' THEN TR.ClaveEmpleado END DESC,
					CASE WHEN @orderByColumn = 'NombreCompletoEmpleado'	and @orderDirection = 'asc'	THEN TR.NombreCompletoEmpleado END,
					CASE WHEN @orderByColumn = 'NombreCompletoEmpleado'	and @orderDirection = 'desc' THEN TR.NombreCompletoEmpleado END DESC,
					TR.IDEmpleado ASC
				OFFSET @PageSize * (@PageNumber - 1) ROWS
				FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

				COMMIT TRAN;

		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
				SELECT @Error = ERROR_MESSAGE()
				RAISERROR(@Error, 16, 1);
		END CATCH

	END
GO
