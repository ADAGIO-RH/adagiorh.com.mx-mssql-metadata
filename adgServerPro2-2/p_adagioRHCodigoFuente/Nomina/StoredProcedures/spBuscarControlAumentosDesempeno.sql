USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [Nomina].[spBuscarControlAumentosDesempeno](
    @IDControlAumentosDesempeno INT = 0,
    @Ejercicio INT = 0,
    @IDUsuario INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 2147483647,
    @query VARCHAR(100) = '""',
    @orderByColumn VARCHAR(50) = 'Ejercicio',
    @orderDirection VARCHAR(4) = 'desc'
    
) AS
BEGIN
    DECLARE 
        @TotalPaginas INT = 0,
        @TotalRegistros INT;

    IF (ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
    IF (ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

    SELECT
         @orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'Ejercicio' ELSE @orderByColumn END,
         @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'desc' ELSE @orderDirection END;

    IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse;
    

    SET @query = CASE 
                    WHEN @query IS NULL THEN '""' 
                    WHEN @query = '' THEN '""'
                    WHEN @query = '""' THEN '""'
                    ELSE '"'+@query + '*"' 
                END;

    -- Consulta principal con ROW_NUMBER
    SELECT 
         cad.* 
    INTO #TempResponse
    FROM Nomina.tblControlAumentosDesempeno cad WITH (NOLOCK)
    WHERE (cad.IDControlAumentosDesempeno = @IDControlAumentosDesempeno OR @IDControlAumentosDesempeno = 0)
        AND (cad.Ejercicio = @Ejercicio OR @Ejercicio = 0)
        
        AND (@query = '""' OR CONTAINS(cad.*, @query));

    -- Calcular paginación
    SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2)) / CAST(@PageSize AS DECIMAL(20,2)))
    FROM #TempResponse;

    SELECT @TotalRegistros = COUNT(IDControlAumentosDesempeno) 
    FROM #TempResponse;

    -- Retornar resultados con paginación
    SELECT *
        ,TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
        ,ISNULL(@TotalRegistros, 0) AS TotalRegistros
    FROM #TempResponse
    ORDER BY 
        CASE WHEN @orderByColumn = 'Ejercicio' AND @orderDirection = 'asc' THEN Ejercicio END ASC,
        CASE WHEN @orderByColumn = 'Ejercicio' AND @orderDirection = 'desc' THEN Ejercicio END DESC
    OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END;
GO
