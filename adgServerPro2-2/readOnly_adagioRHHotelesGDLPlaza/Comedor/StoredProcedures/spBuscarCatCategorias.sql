USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spBuscarCatCategorias](@IDCategoria	int = 0
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

	if object_id('tempdb..#tempCatCategorias') is not null drop table #tempCatCategorias;

	select 
		[tca].[IDCategoria]
		,[tca].[Nombre]
	INTO #tempCatCategorias
	from [Comedor].[TblCatCategorias] [tca] with(nolock)
	where([tca].[IDCategoria] = @IDCategoria
		or isnull(@IDCategoria,0) = 0)
		and (coalesce(@query,'') = '' or coalesce([tca].Nombre, '') like '%'+@query+'%')

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatCategorias

	select @TotalRegistros = cast(COUNT([IDCategoria]) as decimal(18,2)) from #tempCatCategorias		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCatCategorias
		order by Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
