USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spBuscarCatCategorias](@IDCategoria	int = 0
												,@IDUsuario		int
												,@PageNumber	int = 1
												,@PageSize		int = 2147483647
												,@query		varchar(1000) = '""'
												,@orderByColumn	varchar(50) = null
												,@orderDirection varchar(4) = null
											)
as
	SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 10;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Name' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
						when @query is null then '""' 
						when @query = '' then '""'
						when @query = '""' then '""'
					else '"'+@query + '*"'  end

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #tempCatCategorias ;

	select 
		[tca].[IDCategoria]
		,[tca].[Nombre]
	INTO #tempCatCategorias
	from [Comedor].[TblCatCategorias] [tca] with(nolock)
	where([tca].[IDCategoria] = @IDCategoria
		or isnull(@IDCategoria,0) = 0)
		and (@query = '""' or contains(tca.*, @query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatCategorias

	select @TotalRegistros = COUNT([IDCategoria]) from #tempCatCategorias		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCatCategorias
	order by
		case when @orderByColumn = 'Nombre' and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'and @orderDirection = 'desc'	then Nombre end desc,
		IDCategoria asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

	/*
	exec  [Comedor].[spBuscarCatCategorias] @IDCategoria = 0
										   ,@IDUsuario =1
										   ,@query = '"entrada"'
	
	*/
GO
