USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   proc [Evaluacion360].[spBuscarIndicadores](
	@IDIndicador int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
	,@orderDirection varchar(4) = 'asc'
	,@IDUsuario int
) as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempIndicadores') IS NOT NULL DROP TABLE #TempIndicadores
	
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	select 
		i.IDIndicador
		,i.Nombre
		,i.Descripcion
		,i.IsDefault
		,i.NombreIcono
	INTO #TempIndicadores
	from Evaluacion360.tblCatIndicadores i
	where (i.IDIndicador = @IDIndicador or isnull(@IDIndicador, 0) = 0)
		and (@query = '""' or contains(i.*, @query)) 
	--order by i.Nombre

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempIndicadores

	select @TotalRegistros = COUNT(IDIndicador) from #TempIndicadores		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempIndicadores
	order by 
		--case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		--case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,		
		Nombre asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
