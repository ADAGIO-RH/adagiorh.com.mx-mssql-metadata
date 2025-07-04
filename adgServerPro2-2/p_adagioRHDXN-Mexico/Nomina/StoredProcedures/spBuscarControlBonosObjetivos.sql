USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarControlBonosObjetivos](
    @IDControlBonosObjetivos INT = 0,
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

    SELECT 
         cbo.*,
         cl.IDCliente
    INTO #TempResponse
    FROM Nomina.tblControlBonosObjetivos cbo WITH (NOLOCK)
    INNER JOIN Nomina.tblCatTipoNomina tn WITH (NOLOCK) ON cbo.IDTipoNomina = tn.IDTipoNomina
    INNER JOIN RH.TblCatClientes cl WITH (NOLOCK) ON tn.IDCliente = cl.IDCliente
    WHERE (cbo.IDControlBonosObjetivos = @IDControlBonosObjetivos OR @IDControlBonosObjetivos = 0)
        AND (cbo.Ejercicio = @Ejercicio OR @Ejercicio = 0)
        AND (@query = '""' OR CONTAINS(cbo.*, @query));

    SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2)) / CAST(@PageSize AS DECIMAL(20,2)))
    FROM #TempResponse;

    SELECT @TotalRegistros = COUNT(IDControlBonosObjetivos) 
    FROM #TempResponse;

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
