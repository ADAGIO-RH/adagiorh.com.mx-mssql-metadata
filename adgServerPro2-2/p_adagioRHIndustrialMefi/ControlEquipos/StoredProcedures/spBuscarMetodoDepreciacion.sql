USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [ControlEquipos].[spBuscarMetodoDepreciacion]
      @IDMetodoDepreciacion INT = NULL
	, @IDUsuario INT = 0
	, @PageNumber INT = 1
	, @PageSize INT = 2147483647
	, @query VARCHAR(4000) = NULL
	, @orderByColumn VARCHAR(50) = 'Nombre'
	, @orderDirection VARCHAR(4) = 'asc'
AS
BEGIN
    SET NOCOUNT ON;
		
	DECLARE @TotalPaginas INT = 0
		, @TotalRegistros DECIMAL(18, 2) = 0.00
		, @IDIdioma VARCHAR(20);

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF (@PageNumber = 0)
		SET @PageNumber = 1;

	IF (@PageSize = 0)
		SET @PageSize = 2147483647;
	SET @query = CASE 
			WHEN @query IS NULL
				THEN '""'
			WHEN @query = ''
				THEN '""'
			ELSE '"' + @query + '*"'
			END

	DECLARE @Result TABLE (
		  IDMetodoDepreciacion INT
		, Nombre VARCHAR(4000)		
		, Descripcion VARCHAR(4000)
		, FactorDepreciacion DECIMAL(10,2)
		, PorcentajeMinimo DECIMAL(5,2)
		);


	INSERT @Result
    SELECT IDMetodoDepreciacion, Nombre, Descripcion, FactorDepreciacion, PorcentajeMinimo
    FROM ControlEquipos.tblMetodoDepreciacion
    WHERE /*IDMetodoDepreciacion = @IDMetodoDepreciacion
	AND */( @query = '""' OR CONTAINS (*,@query));

	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20, 2)) / cast(@PageSize AS DECIMAL(20, 2)))
	FROM @Result

	SELECT @TotalRegistros = cast(COUNT(IDMetodoDepreciacion) AS DECIMAL(18, 2))
	FROM @Result

	SELECT *
		, TotalPaginas = CASE 
			WHEN @TotalPaginas = 0
				THEN 1
			ELSE @TotalPaginas
			END
	FROM @Result
	ORDER BY 
		  CASE WHEN @orderByColumn = 'Nombre' AND @orderDirection = 'asc' THEN Nombre END
		, CASE WHEN @orderByColumn = 'Nombre' AND @orderDirection = 'desc' THEN Nombre END
		, CASE WHEN @orderByColumn = 'Descripcion' AND @orderDirection = 'asc' THEN Descripcion END
		, CASE WHEN @orderByColumn = 'Descripcion' AND @orderDirection = 'desc' THEN Descripcion END
		, Nombre ASC 
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY
	OPTION (RECOMPILE);

END


/*
exec [ControlEquipos].[spBuscarMetodoDepreciacion] @IDMetodoDepreciacion = 0

select * from ControlEquipos.tblMetodoDepreciacion
*/
GO
