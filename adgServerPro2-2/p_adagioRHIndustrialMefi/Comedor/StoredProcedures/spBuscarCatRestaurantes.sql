USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spBuscarCatRestaurantes](@IDRestaurante   int = 0
											   ,@SoloDisponibles bit = null
											   ,@IDUsuario       int
											   ,@PageNumber	int = 1
											   ,@PageSize		int = 2147483647
											   ,@query			varchar(1000) = ''
											   ,@orderByColumn	varchar(100) = 'Nombre'
											   ,@orderDirection varchar(4) = 'asc'
											   )
as
	SET FMTONLY OFF;  
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@IDIdioma varchar(20);

		if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
		if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
		set @query = case 
						when @query is null then '""' 
						when @query = '' then '""'
						when @query = '""' then '""'
					else '"'+@query + '*"'  end

		select
			 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
			,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

		IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
		IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse

	 select 
			[R].[IDRestaurante]
		   ,[R].[Nombre]
		   ,isnull([R].[Disponible],0) as [Disponible]
	  into #TempResponse
	  from [Comedor].[tblCatRestaurantes] [R] with(nolock)
	  where([R].[IDRestaurante] = @IDRestaurante
			or isnull(@IDRestaurante,0) = 0)
		   and (isnull([R].[Disponible],0) = case
												 when @SoloDisponibles = 1
												 then 1
												 else isnull([R].[Disponible],0)
											 end)
											 and (@query = '""' or contains([R].*, @query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDRestaurante) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'asc'	then Nombre end,			
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'desc'then Nombre end desc,
		IDRestaurante asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


	/*
	exec Comedor.[spBuscarCatRestaurantes]
		@IDRestaurante = 0
		,@SoloDisponibles = null
		,@IDUsuario = 1
		--,@PageNumber	int = 1
		--,@PageSize		int = 10
		,@query			 = '"PATI"'
		--,@orderByColumn	varchar(50) = 'IDRestaurante'
		--,@orderDirection varchar(4) = 'asc'
	
	
	*/
GO
