USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarDetallePrestamo]
(
	@IDPrestamo int
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'FechaPago'
    ,@orderDirection varchar(4) = 'desc'   
    
)
AS
BEGIN
    IF OBJECT_ID('TEMPDB..#TempAbonosPrestamo') IS NOT NULL  
    DROP TABLE #TempAbonosPrestamo

        DECLARE  
	   @TotalPaginas INT = 0
	   ,@TotalRegistros INT, 
		@IDIdioma VARCHAR(20)
	;

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma',1, 'esmx')

	IF (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	IF (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	SELECT
		 @orderByColumn	 = CASE WHEN @orderByColumn	 IS NULL THEN 'FechaPago' ELSE @orderByColumn  END
		,@orderDirection = CASE WHEN @orderDirection IS NULL THEN  'desc' ELSE @orderDirection END

	SET @query = CASE
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				    ELSE '"'+@query + '*"' END


	SELECT * 
    INTO #TempAbonosPrestamo
	FROM Nomina.fnPagosPrestamo(@IDPrestamo)
    
    
    
     select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempAbonosPrestamo

	select @TotalRegistros = cast(COUNT(IDPrestamo) as decimal(18,2)) from #TempAbonosPrestamo
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempAbonosPrestamo
	order by 	
		case when @orderByColumn = 'FechaPago' and @orderDirection = 'asc'	then FechaPago end,			
		case when @orderByColumn = 'FechaPago' and @orderDirection = 'desc'	then FechaPago end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
