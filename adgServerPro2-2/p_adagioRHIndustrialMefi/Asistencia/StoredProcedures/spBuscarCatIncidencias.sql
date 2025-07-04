USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Asistencia].[spBuscarCatIncidencias](  
		@IDIncidencia VARCHAR(10) = null,
		@IDUsuario INT,
		@PageNumber	INT = 1,
		@PageSize INT = 2147483647,
		@query VARCHAR(100) = '""',
		@orderByColumn	VARCHAR(50) = 'IDIncidencia',
		@orderDirection VARCHAR(4) = 'asc'
) AS  
BEGIN
	SET FMTONLY OFF;
	
	IF OBJECT_ID('tempdb..#TempIncidencias') IS NOT NULL DROP TABLE #TempIncidencias  
	
	DECLARE  
		@IDIdioma varchar(225),
		@TotalPaginas INT = 0,
		@TotalRegistros DECIMAL(18,2) = 0.00
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF(isnull(@PageSize, 0) = 0) SET @PageSize = 2147483647;
	
	SELECT
		 @orderByColumn	= CASE WHEN @orderByColumn	IS NULL THEN 'IDIncidencia' ELSE @orderByColumn END,
		 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'asc' ELSE @orderDirection END 
	
	SELECT ID
	INTO #TempIncidencias  
	FROM Seguridad.tblFiltrosUsuarios WITH(NOLOCK)  
	WHERE IDUsuario = @IDUsuario AND Filtro = 'IncidenciasAusentismos' 

	SET @query = CASE 
					WHEN @query IS NULL THEN '""' 
					WHEN @query = ''	THEN '""'
					WHEN @query = '""'	THEN @query
				 ELSE '"' + @query + '*"' END

	DECLARE @tempResponse AS TABLE (
		 IDIncidencia		VARCHAR(10),
		 Descripcion		VARCHAR(255),
		 EsAusentismo		BIT,
		 GoceSueldo			BIT,
		 PermiteChecar		BIT,
		 AfectaSUA			BIT,
		 TiempoIncidencia	BIT,
		 Color				VARCHAR(20),
		 Autorizar			BIT,
		 GenerarIncidencias BIT,
		 Intranet			BIT,
		 AdministrarSaldos	BIT,
		 Traduccion			varchar(max),
		 ReportePapeleta	varchar(max),
		 NombreProcedure    Varchar(max),
		 ROWNUMBER			INT
	);

	INSERT @tempResponse
	SELECT 
		IDIncidencia,
		JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,
		EsAusentismo,
		GoceSueldo,
		PermiteChecar,
		AfectaSUA,
		TiempoIncidencia,
		ISNULL(Color,'#000000') AS Color,
		Autorizar,
		ISNULL(GenerarIncidencias,0) AS GenerarIncidencias,
		ISNULL(Intranet,0) AS Intranet,
		AdministrarSaldos,
		Traduccion,
		ReportePapeleta,
		NombreProcedure,
		ROW_NUMBER()OVER(ORDER BY IDIncidencia) AS ROWNUMBER  
    FROM [Asistencia].[tblCatIncidencias] WITH(NOLOCK)  
    WHERE ((IDIncidencia = @IDIncidencia) OR (@IDIncidencia IS NULL)) AND
		  (IDIncidencia IN (SELECT ID FROM #TempIncidencias) OR NOT EXISTS(SELECT ID FROM #TempIncidencias)) AND
		  (@query = '""' OR CONTAINS(*, @query))


	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM @tempResponse

	SELECT @TotalRegistros = CAST(COUNT([IDIncidencia]) AS DECIMAL(18,2)) FROM @tempResponse		

	SELECT *,
		   TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
	FROM @tempResponse
	ORDER BY 
		CASE WHEN @orderByColumn = 'IDIncidencia'	and @orderDirection = 'asc'	then IDIncidencia end,			
		CASE WHEN @orderByColumn = 'IDIncidencia'	and @orderDirection = 'desc' then IDIncidencia end desc,			
		CASE WHEN @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	then Descripcion end,			
		CASE WHEN @orderByColumn = 'Descripcion'	and @orderDirection = 'desc' then Descripcion end desc,				
		IDIncidencia asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
