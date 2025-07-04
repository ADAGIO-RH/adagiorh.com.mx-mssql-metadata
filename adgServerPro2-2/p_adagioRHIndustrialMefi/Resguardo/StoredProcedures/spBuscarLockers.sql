USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Resguardo].[spBuscarLockers](
	@IDLocker int = 0	
	,@IDCaseta int = 0	
	,@IDUsuario int
	,@PageNumber int = 1
	,@PageSize int = 2147483647
	,@query varchar(max) = ''
) as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempCatLockers') is not null drop table #tempCatLockers;
	select 
		l.IDLocker
		,l.IDCaseta
		,c.Nombre as Caseta
		,l.Codigo
		,l.Disponible
		,l.Activo
		,isnull(l.FechaHora,getdate()) as FechaHora
		,Orden = ROW_NUMBER()over(order by cast(l.Codigo as int) asc)
	INTO #tempCatLockers
	from [Resguardo].[tblCatLockers] l with (nolock)
		join [Resguardo].[tblCatCasetas] c with (nolock) on l.IDCaseta = c.IDCaseta
	where (l.IDLocker = @IDLocker or @IDLocker = 0) and (c.IDCaseta = @IDCaseta) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatLockers

	select @TotalRegistros = cast(COUNT(IDLocker) as decimal(18,2)) from #tempCatLockers		
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCatLockers
		order by Orden asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

	--select *
	--from (
	--) as cat
	--order by cat.Orden asc
GO
