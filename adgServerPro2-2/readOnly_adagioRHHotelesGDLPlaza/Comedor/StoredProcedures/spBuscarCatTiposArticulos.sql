USE [readOnly_adagioRHHotelesGDLPlaza]
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
												,@query		varchar(max) = ''
											)
as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

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
		and (coalesce(@query,'') = '' or coalesce([cta].Nombre, '')+' '+coalesce([cta].Descripcion, '') like '%'+@query+'%')

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatTiposArticulos

	select @TotalRegistros = cast(COUNT([IDTipoArticulo]) as decimal(18,2)) from #tempCatTiposArticulos		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCatTiposArticulos
		order by Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
