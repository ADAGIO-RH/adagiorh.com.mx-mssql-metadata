USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Tipos de notificaciones
** Autor			: ?
** Email			: ?
** FechaCreacion	: ?
** Paremetros		: @IDTipoNotificacion	Identificador del TipoNotificacion
**					: @MedioNotificacion	Identificador del MedioNotificacion
**					: @IDUsuario			Identificador del usuario
**					: @PageNumber			Número de pagina solicitada
**					: @PageSize				Número de registros solicitados
**					: @query				Texto para buscar un registro en especifico
**					: @orderByColumn		Ordenamiento de los registros por columna solicitada
**					: @orderDirection		Ordenamiento de los registros en ascendente o descendente

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2023-08-22			Jose Vargas	        Se agrega paginación
2023-08-22			Jose Vargas	        Se agrega columna SourceEmailDefault  
2024-10-12			Alejandro Paredes	Se filtraron las notificaciones activas por la propiedad "IsActivo"
***************************************************************************************************/
CREATE PROC [App].[spBuscarConfiguracionTiposNotificaciones] 
(
    @IDTipoNotificacion		VARCHAR(50)	= NULL
	, @MedioNotificacion	VARCHAR(50) = NULL
	, @IDUsuario			INT = NULL
	, @PageNumber			INT = 1
	, @PageSize				INT = 2147483647
	, @query				VARCHAR(100) = NULL
	, @orderByColumn		VARCHAR(50) = 'IDTipoNotificacion'
	, @orderDirection		VARCHAR(4) = 'asc'
) AS

    DECLARE @TotalPaginas INT = 0
			, @TotalRegistros DECIMAL(18,2) = 0.00
			, @IDIdioma VARCHAR(20)
			, @SI BIT = 1
			;
	
	SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');

	IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

	SELECT @orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'IDTipoNotificacion' ELSE @orderByColumn END
			, @orderDirection = CASE WHEN @orderDirection IS NULL THEN  'asc' ELSE @orderDirection END

	SET @query = CASE
					WHEN @query = '' 
						THEN NULL
						ELSE @query 
					END

    IF OBJECT_ID('tempdb..#TempTiposNotificaciones') IS NOT NULL DROP TABLE #TempTiposNotificaciones
    
    SELECT NOTI.IDTipoNotificacion
			, Descripcion
			, Asunto
			, NOTI.Nombre
			, COALESCE(IsSpecial, 0) [IsSpecial]
			, ISNULL(CATCONFIG.Nombre, '') NombreConfiguracion
			, ISNULL(CATCONFIG.IDTipoConfiguracionNotificacion, 0) AS [IDTipoConfiguracionNotificacion]
    INTO #TempTiposNotificaciones
    FROM [App].[tblTiposNotificaciones] NOTI
		LEFT JOIN [App].[tblConfiguracionTiposNotificaciones] CONFI ON CONFI.IDTipoNotificacion = NOTI.IDTipoNotificacion
		LEFT JOIN [App].[tblCatTiposConfiguracionesNotificaciones] CATCONFIG ON CONFI.IDTipoConfiguracionNotificacion = CATCONFIG.IDTipoConfiguracionNotificacion
    WHERE (NOTI.IDTipoNotificacion = @IDTipoNotificacion OR @IDTipoNotificacion IS NULL OR @IDTipoNotificacion = '')
			AND NOTI.IsActivo = @SI


    SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2)) / CAST(@PageSize AS DECIMAL(20,2)))
	FROM #TempTiposNotificaciones;

	SELECT @TotalRegistros = CAST(COUNT([IDTipoNotificacion]) AS DECIMAL(18,2)) FROM #TempTiposNotificaciones;
	
	SELECT *
			, TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
			, CAST(@TotalRegistros AS INT) AS TotalRows
	FROM #TempTiposNotificaciones
	ORDER BY
			CASE WHEN @orderByColumn = 'IDTipoNotificacion' AND @orderDirection = 'asc'	THEN IDTipoNotificacion END,
			CASE WHEN @orderByColumn = 'IDTipoNotificacion' AND @orderDirection = 'desc' THEN IDTipoNotificacion END DESC
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
