USE [readOnly_adagioRHHotelesGDLPlaza]
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
											,@query		varchar(max) = ''
										)
as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempCatTiposMenus') is not null drop table #tempCatTiposMenus;

	select 
		[ctm].[IDTipoMenu]
		,[ctm].[Nombre]
		,[ctm].[Descripcion]
		,[ctm].[HoraDisponibilidadInicio]
		,[ctm].[HoraDisponibilidadFin]
		,isnull([Ctm].[Disponible],0) as                    [Disponible]
		,isnull([Ctm].[FechaHora],'1990-01-01 00:00:00') as [FechaHora]
	INTO #tempCatTiposMenus
	from [Comedor].[tblCatTiposMenus] [ctm] with(nolock)
	where([ctm].[IDTipoMenu] = @IDTipoMenu
		or isnull(@IDTipoMenu,0) = 0)
		and (isnull([Ctm].[Disponible],0) = case
												when @SoloDisponibles = 1
												then 1
												else [Ctm].[Disponible]
											end)
		and (coalesce(@query,'') = '' or coalesce([ctm].Nombre, '')+' '+coalesce([ctm].Descripcion, '') like '%'+@query+'%')

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatTiposMenus

	select @TotalRegistros = cast(COUNT(IDTipoMenu) as decimal(18,2)) from #tempCatTiposMenus		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCatTiposMenus
		order by Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
