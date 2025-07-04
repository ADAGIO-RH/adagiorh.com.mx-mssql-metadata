USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [APP].[spBuscarNavegadores](      
	@IDNavegador INT = NULL,
	@IDUsuario INT,
	@PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = 'Codigo',
	@orderDirection VARCHAR(4) = 'asc'
)      
AS      
BEGIN  

	SET FMTONLY OFF;

	DECLARE  
	   @TotalPaginas INT = 0,
	   @TotalRegistros DECIMAL(18,2) = 0.00;
 
	IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF(isnull(@PageSize, 0) = 0) SET @PageSize = 2147483647;

	SELECT
		 @orderByColumn	= CASE WHEN @orderByColumn	IS NULL THEN 'Codigo' ELSE @orderByColumn END,
		 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'asc' ELSE @orderDirection END 

	DECLARE @TempNavegadores AS TABLE (
		ID INT
	)
  
	--SELECT * FROM Seguridad.tblFiltrosUsuarios  
	--INSERT @TempNavegadores
	--SELECT ID   
	--FROM Seguridad.tblFiltrosUsuarios   
	--WHERE IDUsuario = @IDUsuario AND Filtro = 'Sucursales'  
   
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then @query
				else '"'+@query + '*"' end

	DECLARE @tempResponse AS TABLE (
		 IDNavegador    INT,
		 Codigo			VARCHAR(20),
		 Nombre			VARCHAR(30)
	);

	INSERT @tempResponse
	SELECT       
		S.IDNavegador,
		S.Codigo,
		S.Nombre       
	FROM [App].[tblNavegadores] S WITH (NOLOCK)
	WHERE ((S.IDNavegador = @IDNavegador OR ISNULL(@IDNavegador,0) = 0)) AND
		  --(S.IDNavegador IN (SELECT ID FROM @TempNavegadores) OR NOT EXISTS(SELECT ID FROM @TempNavegadores)) AND 
		  (@query = '""' OR CONTAINS(s.*, @query)) 
	
	
	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM @tempResponse

	SELECT @TotalRegistros = CAST(COUNT([IDNavegador]) AS DECIMAL(18,2)) FROM @tempResponse		

	SELECT *,
		   TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
	FROM @tempResponse
	ORDER BY 
		CASE WHEN @orderByColumn = 'Codigo'	and @orderDirection = 'asc'	then Codigo end,			
		CASE WHEN @orderByColumn = 'Codigo'	and @orderDirection = 'desc' then Codigo end desc,			
		CASE WHEN @orderByColumn = 'Nombre'	and @orderDirection = 'asc'	then Nombre end,			
		CASE WHEN @orderByColumn = 'Nombre'	and @orderDirection = 'desc' then Nombre end desc,				
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
