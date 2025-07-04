USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spBuscarCatTiposMenus](@IDTipoMenu      int = 0
											,@SoloDisponibles bit = null
											,@IDUsuario       int
											,@PageNumber	int = 1
											,@PageSize		int = 2147483647
											,@query		varchar(1000) = '""'
											,@orderByColumn	varchar(100) = 'Nombre'
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

		set @query = case 
						when @query is null then '""' 
						when @query = '' then '""'
						when @query = '""' then '""'
		else '"' + @query + '*"' end

		select
			 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
			,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempResponse') is not null drop table ##tempResponse;

	select 
		[ctm].[IDTipoMenu]
		,[ctm].[Nombre]
		,[ctm].[Descripcion]
		,[ctm].[HoraDisponibilidadInicio]
		,[ctm].[HoraDisponibilidadFin]
		,isnull([Ctm].[Disponible],0) as                    [Disponible]
		,isnull([Ctm].[FechaHora],'1990-01-01 00:00:00') as [FechaHora]
	INTO #tempResponse
	from [Comedor].[tblCatTiposMenus] [ctm] with(nolock)
	where ([ctm].[IDTipoMenu] = @IDTipoMenu
		or isnull(@IDTipoMenu,0) = 0)
		and (isnull([Ctm].[Disponible],0) = case
												when @SoloDisponibles = 1
												then 1
												else [Ctm].[Disponible]
											end)
		and (@query = '""' or contains([ctm].*, @query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDTipoMenu) from #tempResponse		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
		order by 
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'asc'	then Nombre end,			
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'desc'then Nombre end desc,
		IDTipoMenu asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

	/**
	

	exec [Comedor].[spBuscarCatTiposMenus]
		@IDTipoMenu      = 0
		,@SoloDisponibles  = null
		,@IDUsuario    = 1
		--,@PageNumber	int = 1
		--,@PageSize		int = 2147483647
		,@query		 = ''
		,@orderByColumn	 = 'Nombre'
		,@orderDirection = 'asc'

		select * from [Comedor].[tblCatTiposMenus]
	*/
GO
