USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [STPS].[spBuscarCapacitaciones_Vue](
	@IDCapacitaciones int = null
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
	/*
		usar este set cuando el contenido de todas las columas indexadas sean palabras u oraciones,
		Caso contrario usar: else @query  end
		else '"' + @query + '*"' end hara que se busque todo lo que tenga como inicio @query
		ejem: '"Actua*"' buscara todas las palabras u oraciones que inicien con 'Actua'.
		
		set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"' + @query + '*"' end
	*/

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempCapacitaciones') is not null drop table #tempCapacitaciones;

	select 
		CC.IDCapacitaciones
		,CC.Codigo
		,UPPER(CC.Descripcion) as Descripcion
	into #tempCapacitaciones
	From [STPS].[tblCatCapacitaciones] CC
	where (CC.IDCapacitaciones = @IDCapacitaciones or ISNULL(@IDCapacitaciones, 0) = 0)
		and (@query = '""' OR CONTAINS(CC.*, @query))
		

	select @TotalPaginas =CEILING(cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCapacitaciones

	select @TotalRegistros = count(IDCapacitaciones) from #tempCapacitaciones

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempCapacitaciones
	order by
		case when @orderByColumn = 'Codigo'	and @orderDirection = 'asc'	then Codigo end,
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	then Descripcion end,
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
