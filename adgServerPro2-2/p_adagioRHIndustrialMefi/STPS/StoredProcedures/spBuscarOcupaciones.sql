USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarOcupaciones](
	@IDOcupaciones	int = null
	,@IDUsuario		int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Descripcion'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query =  '""' then '""'
	else '"'+@query + '*"' end

	IF OBJECT_ID('tempdb..#TempOcupaciones') IS NOT NULL DROP TABLE #TempOcupaciones;  
	 

	select 
		o.IDOcupaciones
		,UPPER(o.Codigo) as Codigo
		,UPPER(o.Descripcion) as Descripcion
	INTO #TempOcupaciones
	From [STPS].[tblCatOcupaciones] o
	where (IDOcupaciones = @IDOcupaciones or isnull(@IDOcupaciones, 0) = 0)
		and (@query = '""' or contains(o.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempOcupaciones

	select @TotalRegistros = cast(COUNT(IDOcupaciones) as decimal(18,2)) from #TempOcupaciones		

	select	
		IDOcupaciones
		,Codigo
		,UPPER(Codigo) +' - '+ UPPER(Descripcion) as Descripcion
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempOcupaciones
	order by 	
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,	
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,
		Codigo
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
