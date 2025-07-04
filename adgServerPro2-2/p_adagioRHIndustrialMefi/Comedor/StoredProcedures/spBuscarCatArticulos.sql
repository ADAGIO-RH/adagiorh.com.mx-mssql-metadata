USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spBuscarCatArticulos](
	@IDArticulo			int = 0
	,@IDTipoArticulo	int = 0
	,@SoloDisponibles	bit = 0
	,@SoloCatalogo		bit = 0
	,@IDUsuario     int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
	,@orderDirection varchar(4) = 'asc'
)
as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int 
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = 
	case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query =  '""' then '""'
	else '"'+@query + '*"' end

	if object_id('tempdb..#tempCatArticulos') is not null drop table #tempCatArticulos;

	select 
		[A].[IDArticulo]
		,[A].[IDTipoArticulo]
		,[Cta].[Nombre] as [TipoArticulo]
		,[A].[Nombre]
		,[A].[Descripcion]
		,isnull([A].[PrecioCosto],0.00)					as [PrecioCosto]
		,isnull([A].[PrecioEmpleado],0.00)				as [PrecioEmpleado]
		,isnull([A].[PrecioPublico],0.00)				as [PrecioPublico]
		,isnull([A].[HoraDisponibilidadInicio],'00:00') as [HoraDisponibilidadInicio]
		,isnull([A].[HoraDisponibilidadFin],'00:00')	as [HoraDisponibilidadFin]
		,isnull([A].[VentaIndividual],0)				as [VentaIndividual]
		,isnull([A].[Disponible],0)						as [Disponible]
		,isnull([A].[ArticuloPedido],0)					as [ArticuloPedido]
		,isnull([A].[IDArticuloOriginal],0)				as [IDArticuloOriginal]
		,isnull([A].[FechaHora],getdate())				as [FechaHora]
		,[A].[IdsRestaurantes]
		,isnull([A].[IDCategoria], 0) as [IDCategoria]
		,isnull([cc].Nombre, '[SIN CATEGORIA]') as Categoria
	INTO #tempCatArticulos
	from [Comedor].[tblCatArticulos] [A] with(nolock)
		join [Comedor].[tblCatTiposArticulos] [cta] with(nolock) on [cta].[IDTipoArticulo] = [A].[IDTipoArticulo]
		left join [Comedor].[tblCatCategorias] [cc] with(nolock) on [cc].[IDCategoria] = [A].[IDCategoria]
	where 
		([A].[IDArticulo] = isnull(@IDArticulo,0) or isnull(@IDArticulo,0) = 0)		
		and ([A].[IDTipoArticulo] = @IDTipoArticulo or isnull(@IDTipoArticulo,0) = 0)	
		and (isnull(a.[ArticuloPedido],0)	= case when isnull(@SoloCatalogo,0)		= 1 then 1 else isnull(a.[ArticuloPedido],0)	end) 
		and (isnull(a.[Disponible],0)		= case when isnull(@SoloDisponibles,0)	= 1 then 1 else isnull(a.[Disponible],0)		end) 
		and (contains(A.*, @query) or @query = '""') 
		
		--(coalesce(@query,'') = '' or coalesce(A.Nombre, '')+' '+coalesce(A.Descripcion, '') like '%'+@query+'%')
	--order by cta.Nombre asc, ltrim(rtrim(a.Nombre)) asc

	select @TotalPaginas = CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatArticulos

	select @TotalRegistros = cast(COUNT([IDArticulo]) as decimal(18,2)) from #tempCatArticulos		
	
	select	*
		,OpcionesArticulo = (
			select 
				op.IDOpcionArticulo	
				,op.IDArticulo			
				,op.Nombre				
				,isnull(op.PrecioExtra,0) as PrecioExtra
				,isnull(op.Disponible,0) as Disponible		
			from Comedor.tblOpcionesArticulo op
			where op.IDArticulo = ca.IDArticulo --Julio Castillo 
			for json auto 
		)
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempCatArticulos ca
	order by 	
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,	
		case when @orderByColumn = 'TipoArticulo'	and @orderDirection = 'asc'		then TipoArticulo end,			
		case when @orderByColumn = 'TipoArticulo'	and @orderDirection = 'desc'	then TipoArticulo end desc,
		case when @orderByColumn = 'Categoria'		and @orderDirection = 'asc'		then Categoria end,			
		case when @orderByColumn = 'Categoria'		and @orderDirection = 'desc'	then Categoria end desc,
		case when @orderByColumn = 'PrecioEmpleado'		and @orderDirection = 'asc'		then PrecioEmpleado end,			
		case when @orderByColumn = 'PrecioEmpleado'		and @orderDirection = 'desc'	then PrecioEmpleado end desc,
		case when @orderByColumn = 'VentaIndividual'	and @orderDirection = 'asc'		then VentaIndividual end,			
		case when @orderByColumn = 'VentaIndividual'	and @orderDirection = 'desc'	then VentaIndividual end desc,
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
