USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Resguardo].[spBuscarCatCasetas](
	@IDCaseta int = 0
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

	if object_id('tempdb..#tempCatCasetas') is not null drop table #tempCatCasetas;

	select 
		c.IDCaseta
		,c.Nombre
		,c.Activa
		,isnull(c.FechaHora,getdate()) as FechaHora
	INTO #tempCatCasetas
	from [Resguardo].[tblCatCasetas] c with (nolock)
	where c.IDCaseta = @IDCaseta or @IDCaseta = 0

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatCasetas

	select @TotalRegistros = cast(COUNT(IDCaseta) as decimal(18,2)) from #tempCatCasetas		
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCatCasetas
		order by Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
