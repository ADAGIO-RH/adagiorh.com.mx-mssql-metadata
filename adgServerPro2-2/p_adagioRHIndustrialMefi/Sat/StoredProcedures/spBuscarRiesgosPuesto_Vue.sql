USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Sat].[spBuscarRiesgosPuesto_Vue](
	@IDRiesgoPuesto int = null
	,@PageNumber INT = 1
	,@PageSize INT = 2147483647
	,@query VARCHAR(4000) = '""'
	,@orderByColumn VARCHAR(50) = 'Codigo'
	,@orderDirection VARCHAR(4) = 'asc'
)
as
begin
	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+ @query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempRiesgoPuesto') is not null drop table #tempRiesgoPuesto;

	select 
		RP.IDRiesgoPuesto
		,UPPER(RP.Codigo) as Codigo
		,UPPER(RP.Descripcion) as Descripcion
	into #tempRiesgoPuesto
	From [Sat].[tblCatRiesgosPuesto] RP
	where (RP.IDRiesgoPuesto = @IDRiesgoPuesto or ISNULL(@IDRiesgoPuesto, 0) = 0)
		and (@query = '""'
			  OR (
					  (ISNUMERIC(@query) = 1 AND RP.Codigo = @query)
					  OR (ISNUMERIC(@query) = 0 AND CONTAINS(RP.*, @query))
			))

	select @TotalPaginas =CEILING(cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempRiesgoPuesto

	select @TotalRegistros = count(IDRiesgoPuesto) from #tempRiesgoPuesto

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempRiesgoPuesto
	order by
		case when @orderByColumn = 'Codigo'	and @orderDirection = 'asc'	then Codigo end,
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	then Descripcion end,
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
