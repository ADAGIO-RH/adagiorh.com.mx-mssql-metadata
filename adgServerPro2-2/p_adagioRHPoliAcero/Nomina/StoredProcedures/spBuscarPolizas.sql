USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarPolizas](    
    @IDPoliza int = null,
    @IDUsuario int,     
    @PageNumber int = 1,
    @PageSize int = 2147483647,
    @query varchar(100) = '""',
    @orderByColumn varchar(50) = 'Nombre',
    @orderDirection varchar(4) = 'asc'
)    
AS    
BEGIN    
    SET FMTONLY OFF;  

    DECLARE  
        @TotalPaginas int = 0,
        @TotalRegistros int,
        @IDIdioma varchar(5)
    ;

   	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    IF (ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
    IF (ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

    SELECT
        @orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'Nombre' ELSE @orderByColumn END,
        @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'asc' ELSE @orderDirection END 

    SET @query = CASE 
        WHEN @query IS NULL THEN '""' 
        WHEN @query = '' THEN '""'
        WHEN @query = '""' THEN '""'
        ELSE '"' + @query + '*"' 
    END

    IF OBJECT_ID('tempdb..#TempPolizas') IS NOT NULL DROP TABLE #TempPolizas;
  
    SELECT     
        p.IDPoliza,
        p.IDTipoPoliza,
        JSON_VALUE(tp.Nombre, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoPoliza,
        p.Nombre,
        p.Filtro,
        p.IDUsuario,
        u.Nombre as Usuario,
        p.FechaCreacion,
        ROW_NUMBER() OVER(ORDER BY p.IDPoliza ASC) AS ROWNUMBER   
    INTO #TempPolizas
    FROM [Nomina].[tblPolizas] p WITH (NOLOCK)    
			INNER JOIN [Nomina].[tblCatTiposPolizas] tp WITH (NOLOCK) ON p.IDTipoPoliza = tp.IDTipoPoliza
			INNER JOIN [Seguridad].[tblUsuarios] u WITH (NOLOCK) ON p.IDUsuario = u.IDUsuario
    WHERE (p.IDPoliza = @IDPoliza OR ISNULL(@IDPoliza,0) = 0)    
        AND (@query = '""' OR CONTAINS(p.*, @query));

    SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS decimal(20,2))/CAST(@PageSize AS decimal(20,2)))
    FROM #TempPolizas;

    SELECT @TotalRegistros = CAST(COUNT([IDPoliza]) AS decimal(18,2)) 
    FROM #TempPolizas;
    
    SELECT 
        *,
        TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
        ISNULL(@TotalRegistros, 0) AS TotalRegistros
    FROM #TempPolizas
    ORDER BY     
        CASE WHEN @orderByColumn = 'Nombre' AND @orderDirection = 'asc' THEN Nombre END,            
        CASE WHEN @orderByColumn = 'Nombre' AND @orderDirection = 'desc' THEN Nombre END DESC,        
        Nombre ASC
    OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
