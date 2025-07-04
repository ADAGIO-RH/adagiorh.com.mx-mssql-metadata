USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción     : Busca detalles de control de aumentos de desempeño en formato mini.
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2025-01-10
** Parámetros      : 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [Nomina].[spBuscarControlAumentosDesempenoDetalleMini]
    @IDControlAumentosDesempeno INT = 0,
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

    IF OBJECT_ID('tempdb..#TempControlAumentosDesempenoDetalle') IS NOT NULL DROP TABLE #TempControlAumentosDesempenoDetalle;

        SELECT 
        CAD.IDControlAumentosDesempenoDetalle,
        CAD.IDControlAumentosDesempeno,
        CAD.IDEmpleado,
        EM.ClaveEmpleado,
        EM.NombreCompleto,
        ISNULL(CS.Descripcion, 'SIN SUCURSAL') AS Sucursal,
        ISNULL(JSON_VALUE(CD.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Descripcion')), 'SIN DEPARTAMENTO') AS Departamento,
        ISNULL(JSON_VALUE(CP.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Descripcion')), 'SIN PUESTO') AS Puesto,
        ISNULL(JSON_VALUE(CP.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE('esmx', '-','')), 'Descripcion')), 'SIN CENTRO DE COSTO') AS CentroCosto,
        Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(CAD.IDEmpleado,0) as UsuarioEmpleadoFotoAvatar
        
    INTO #TempControlAumentosDesempenoDetalle
    FROM [Nomina].[TblControlAumentosDesempenoDetalle] CAD
    INNER JOIN RH.tblEmpleadosMaster EM ON EM.IDEmpleado = CAD.IDEmpleado
    LEFT JOIN RH.tblCatSucursales CS ON CS.IDSucursal = CAD.IDSucursal
    LEFT JOIN RH.tblCatDepartamentos CD ON CD.IDDepartamento = CAD.IDDepartamento
    LEFT JOIN RH.tblCatPuestos CP ON CP.IDPuesto = CAD.IDPuesto
    LEFT JOIN RH.tblCatCentroCosto CC ON CC.IDCentroCosto = CAD.IDCentroCosto
    WHERE (CAD.IDControlAumentosDesempeno = @IDControlAumentosDesempeno OR ISNULL(@IDControlAumentosDesempeno, 0) = 0)
        AND (
            (@query = '""' OR CONTAINS(EM.*, @query)) OR
            (@query = '""' OR CONTAINS(CS.*, @query)) OR
            (@query = '""' OR CONTAINS(CD.*, @query)) OR
            (@query = '""' OR CONTAINS(CP.*, @query))
        );

    SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2)) / CAST(@PageSize AS DECIMAL(20,2)))
    FROM #TempControlAumentosDesempenoDetalle;

    SELECT @TotalRegistros = CAST(COUNT(IDControlAumentosDesempenoDetalle) AS DECIMAL(18,2)) 
    FROM #TempControlAumentosDesempenoDetalle;

    SELECT *,
        TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
        ISNULL(@TotalRegistros, 0) AS TotalRegistros
    FROM #TempControlAumentosDesempenoDetalle
    ORDER BY 
        CASE WHEN @orderByColumn = 'ClaveEmpleado' AND @orderDirection = 'asc' THEN ClaveEmpleado END,
        CASE WHEN @orderByColumn = 'ClaveEmpleado' AND @orderDirection = 'desc' THEN ClaveEmpleado END DESC
    OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
