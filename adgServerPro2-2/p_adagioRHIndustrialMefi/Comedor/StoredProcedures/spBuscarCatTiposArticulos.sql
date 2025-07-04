USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spBuscarCatTiposArticulos](@IDTipoArticulo	int = 0
												,@SoloDisponibles	bit = null
												,@IDUsuario		int
												,@PageNumber	int = 1
												,@PageSize		int = 2147483647
												,@query		varchar(5000) = '""'
												,@orderByColumn	varchar(50) = 'Nombre'
												,@orderDirection varchar(4) = 'asc'
											)
as
	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	set @query = 
	case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query =  '""' then '""'
	else '"'+@query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempCatTiposArticulos') is not null drop table #tempCatTiposArticulos;

	select 
		[Cta].[IDTipoArticulo]
		,[Cta].[Nombre]
		,[Cta].[Descripcion]
		,isnull([Cta].[Disponible],0) as                    [Disponible]
		,isnull([Cta].[Fechahora],'1990-01-01 00:00:00') as [FechaHora]
	INTO #tempCatTiposArticulos
	from [Comedor].[TblCatTiposArticulos] [cta] with(nolock)
	where([cta].[IDTipoArticulo] = @IDTipoArticulo
		or isnull(@IDTipoArticulo,0) = 0)
		and (isnull([cta].[Disponible],0) = case
												when @SoloDisponibles = 1
												then 1
												else [Cta].[Disponible]
											end)
		and (@query = '""' or contains([Cta].*, @query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatTiposArticulos

	select @TotalRegistros = count(IDTipoArticulo) from #tempCatTiposArticulos		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempCatTiposArticulos
	order by
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'asc'	then Nombre end,			
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'desc'then Nombre end desc,
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

	/*
		exec [Comedor].[spBuscarCatTiposArticulos]
			@IDTipoArticulo	= 0
			,@SoloDisponibles = null
			,@IDUsuario	= 1
			,@PageNumber = 1
			,@PageSize	 = 2147483647
			,@query		varchar(max) = ''
			,@orderByColumn	varchar(50) = 'Nombre'
			,@orderDirection varchar(4) = 'asc'
	*/
GO
