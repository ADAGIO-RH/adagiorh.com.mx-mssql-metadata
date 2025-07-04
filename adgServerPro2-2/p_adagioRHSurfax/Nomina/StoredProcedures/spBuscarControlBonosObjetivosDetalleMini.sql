USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarControlBonosObjetivosDetalleMini]
    @IDControlBonosObjetivos INT = 0,
    @PageNumber INT = 1,
    @PageSize INT = 2147483647,
    @query VARCHAR(100) = '""',
    @orderByColumn VARCHAR(50) = 'ClaveEmpleado',
    @orderDirection VARCHAR(4) = 'desc',
    @IDUsuario INT
AS
BEGIN
    DECLARE 
        @TotalPaginas INT = 0,
        @TotalRegistros INT,
        @IDIdioma VARCHAR(20);

    SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

    IF (ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
    IF (ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

    SELECT
        @orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'ClaveEmpleado' ELSE @orderByColumn END,
        @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'desc' ELSE @orderDirection END;

    SET @query = CASE
                    WHEN @query IS NULL THEN '""' 
                    WHEN @query = '' THEN '""'
                    WHEN @query = '""' THEN '""'
                    ELSE '"' + @query + '*"' END;

    IF OBJECT_ID('tempdb..#TempControlBonosObjetivosDetalle') IS NOT NULL DROP TABLE #TempControlBonosObjetivosDetalle;

    SELECT 
        CBD.IDControlBonosObjetivosDetalle,
        CBD.IDControlBonosObjetivos,
        CBD.IDEmpleado,
        EM.ClaveEmpleado,
        EM.NombreCompleto,
        ISNULL(CS.Descripcion, 'SIN SUCURSAL') AS Sucursal,
        ISNULL(JSON_VALUE(CD.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Descripcion')), 'SIN DEPARTAMENTO') AS Departamento,
        ISNULL(JSON_VALUE(CP.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Descripcion')), 'SIN PUESTO') AS Puesto,
        ISNULL(JSON_VALUE(CP.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Descripcion')), 'SIN CENTRO DE COSTO') AS CentroCosto,
        Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(CBD.IDEmpleado,0) as UsuarioEmpleadoFotoAvatar
        
    INTO #TempControlBonosObjetivosDetalle
    FROM [Nomina].[tblControlBonosObjetivosDetalle] CBD
    INNER JOIN RH.tblEmpleadosMaster EM ON EM.IDEmpleado = CBD.IDEmpleado
    LEFT JOIN RH.tblCatSucursales CS ON CS.IDSucursal = CBD.IDSucursal
    LEFT JOIN RH.tblCatDepartamentos CD ON CD.IDDepartamento = CBD.IDDepartamento
    LEFT JOIN RH.tblCatPuestos CP ON CP.IDPuesto = CBD.IDPuesto
    LEFT JOIN RH.tblCatCentroCosto CC ON CC.IDCentroCosto = CBD.IDCentroCosto
    WHERE (CBD.IDControlBonosObjetivos = @IDControlBonosObjetivos OR ISNULL(@IDControlBonosObjetivos, 0) = 0)
        AND (
            (@query = '""' OR CONTAINS(EM.*, @query)) OR
            (@query = '""' OR CONTAINS(CS.*, @query)) OR
            (@query = '""' OR CONTAINS(CD.*, @query)) OR
            (@query = '""' OR CONTAINS(CP.*, @query))
        );

    SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2)) / CAST(@PageSize AS DECIMAL(20,2)))
    FROM #TempControlBonosObjetivosDetalle;

    SELECT @TotalRegistros = CAST(COUNT(IDControlBonosObjetivosDetalle) AS DECIMAL(18,2)) 
    FROM #TempControlBonosObjetivosDetalle;

    SELECT *,
        TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
        ISNULL(@TotalRegistros, 0) AS TotalRegistros
    FROM #TempControlBonosObjetivosDetalle
    ORDER BY 
        CASE WHEN @orderByColumn = 'ClaveEmpleado' AND @orderDirection = 'asc' THEN ClaveEmpleado END,
        CASE WHEN @orderByColumn = 'ClaveEmpleado' AND @orderDirection = 'desc' THEN ClaveEmpleado END DESC
    OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
