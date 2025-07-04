USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Nomina].[spBuscarCatTipoDisposicionMonetaria]    
(    
 	@IDTipoDisposicionMonetaria int = null
	 ,@IDUsuario int = null    
	 ,@PageNumber	int = 1
	 ,@PageSize		int = 2147483647
	 ,@query			varchar(100) = '""'
	 ,@orderByColumn	varchar(50) = 'Descripcion'
	 ,@orderDirection varchar(4) = 'asc'
)    
AS    
BEGIN    
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		 d.IDTipoDisposicionMonetaria    
		,d.Descripcion    
	into #tempResponse
	FROM [Nomina].[tblCatTipoDisposicionMonetaria] d with(nolock)     
	WHERE

		( 
			
            (d.IDTipoDisposicionMonetaria = @IDTipoDisposicionMonetaria or isnull(@IDTipoDisposicionMonetaria,0) =0)
        )  
		and (@query = '""' or contains(d.*, @query)) 
	ORDER BY d.Descripcion ASC    

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDTipoDisposicionMonetaria) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,		
		Descripcion asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
