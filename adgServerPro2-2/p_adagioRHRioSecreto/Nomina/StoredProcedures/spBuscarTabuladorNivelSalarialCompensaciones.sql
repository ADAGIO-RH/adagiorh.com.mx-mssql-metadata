USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [Nomina].[spBuscarTabuladorNivelSalarialCompensaciones] (
     @IDTabuladorNivelSalarialCompensaciones int = 0
	,@Ejercicio int = 0
	,@IDUsuario int = null
	,@PageNumber int = 1
	,@PageSize int = 2147483647
	,@query varchar(100) = '""'
	,@orderByColumn varchar(50) = 'Ejercicio'
	,@orderDirection varchar(4) = 'desc'
	,@ValidarFiltros bit = 1
) AS
BEGIN
	DECLARE  
	   @TotalPaginas int = 0,
	   @TotalRegistros int;

	IF (ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF (ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

	
	SELECT
		 @orderByColumn	 = CASE WHEN @orderByColumn IS NULL THEN 'Ejercicio' ELSE @orderByColumn END,
		 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'desc' ELSE @orderDirection END;

	
	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse;

	
	SELECT ID   
	INTO #TempFiltros  
	FROM Seguridad.tblFiltrosUsuarios WITH(NOLOCK)
	WHERE IDUsuario = @IDUsuario AND Filtro = 'TabuladorNivelSalarialCompensaciones';

	
	SET @query = CASE 
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query = '""' THEN '""'
					ELSE '"'+@query + '*"' 
				END;

	-- Consulta principal con ROW_NUMBER
	SELECT 
		 tns.IDTabuladorNivelSalarialCompensaciones
		,tns.Ejercicio
		,tns.Descripcion
		,ROWNUMBER = ROW_NUMBER() OVER (ORDER BY 
			CASE WHEN @orderByColumn = 'Ejercicio' AND @orderDirection = 'desc' THEN tns.Descripcion END ASC,
			CASE WHEN @orderByColumn = 'Ejercicio' AND @orderDirection = 'desc' THEN tns.Descripcion END DESC,
			tns.Descripcion ASC
		)
	INTO #TempResponse
	FROM Nomina.tblTabuladorNivelSalarialCompensaciones tns WITH (NOLOCK)
	WHERE (tns.IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones OR @IDTabuladorNivelSalarialCompensaciones = 0)
		AND (tns.Ejercicio = @Ejercicio OR @Ejercicio = 0)
		AND (tns.IDTabuladorNivelSalarialCompensaciones IN (SELECT ID FROM #TempFiltros) 
			OR NOT EXISTS (SELECT ID FROM #TempFiltros) OR @ValidarFiltros = 0)
		AND (@query = '""' OR CONTAINS(tns.*, @query));

	-- Calcular paginación
	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2)) / CAST(@PageSize AS DECIMAL(20,2)))
	FROM #TempResponse;

	SELECT @TotalRegistros = COUNT(IDTabuladorNivelSalarialCompensaciones) 
	FROM #TempResponse;

	-- Retornar resultados con paginación
	SELECT *
		,TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
		,ISNULL(@TotalRegistros, 0) AS TotalRegistros
	FROM #TempResponse
	ORDER BY 
		CASE WHEN @orderByColumn = 'Ejercicio' AND @orderDirection = 'asc' THEN Ejercicio END ASC,
		CASE WHEN @orderByColumn = 'Ejercicio' AND @orderDirection = 'desc' THEN Ejercicio END DESC,
		Ejercicio DESC
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END;
GO
