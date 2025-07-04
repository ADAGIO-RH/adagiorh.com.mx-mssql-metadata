USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spBuscarCatMenus](@IDMenu			int = 0
										,@IDTipoMenu	int = 0
										,@SoloCatalogo	bit = 0
										,@IDUsuario		int
										,@PageNumber	int = 1
										,@PageSize		int = 2147483647
										,@query			varchar(max) = ''
									)
as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempCatMenus') is not null drop table #tempCatMenus;

	select 
		[M].[IDMenu]
		,[M].[IDTipoMenu]
		,[Ctm].[Nombre] as	[TipoMenu]
		,[M].[Nombre]
		,[M].[Descripcion]
		,isnull([M].[PrecioCosto],0.00)							as [PrecioCosto]
		,isnull([M].[PrecioEmpleado],0.00)						as [PrecioEmpleado]
		,isnull([M].[PrecioPublico],0.00)						as [PrecioPublico]
		,isnull([M].[DisponibilidadPorFecha],0)					as [DisponibilidadPorFecha]
		,isnull([M].[FechaDisponibilidadInicio],'1990-01-01')	as [FechaDisponibilidadInicio]
		,isnull([M].[FechaDisponibilidadFin],'1990-01-01')		as [FechaDisponibilidadFin]
		,isnull([M].[Disponible],0)								as [Disponible]
		,isnull([M].[MenuPedido],0)								as [MenuPedido]
		,isnull([M].[IDMenuOriginal],0)							as [IDMenuOriginal]
		,isnull([M].[FechaHora], getdate())						as [FechaHora]
		,isnull([M].[MenuDelDia], 0)							as [MenuDelDia]
		,isnull([M].[HistorialDisponibilidad], 0)				as [HistorialDisponibilidad]
		,[M].[IdsRestaurantes]
	INTO #tempCatMenus
	from [Comedor].[tblCatMenus] [M] with(nolock)
		join [Comedor].[tblCatTiposMenus] [Ctm] with(nolock) on [Ctm].[IDTipoMenu] = [M].[IDTipoMenu]
	where ([M].[IDMenu] = @IDMenu or isnull(@IDMenu,0) = 0)
		and ([M].[IDTipoMenu] = isnull(@IDTipoMenu,0) or isnull(@IDTipoMenu,0) = 0)
		and (isnull([M].[MenuPedido],0) = case
											when isnull(@SoloCatalogo,0) = 1
											then 0
											else [M].[MenuPedido]
										end)
	and (coalesce(@query,'') = '' or coalesce([M].Nombre, '')+' '+coalesce([M].Descripcion, '') like '%'+@query+'%')

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatMenus

	select @TotalRegistros = cast(COUNT(IDMenu) as decimal(18,2)) from #tempCatMenus		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCatMenus
	order by Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
