USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarPaises](
	@IDPais int = null
	,@PageNumber INT = 1
	,@PageSize INT = 2147483647
	,@query VARCHAR(4000) = '""'
	,@orderByColumn VARCHAR(50) = 'Codigo'
	,@orderDirection VARCHAR(4) = 'asc'
)
AS
BEGIN
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

	if object_id('tempdb..#tempPaises') is not null drop table #tempPaises;

	select 
		cp.IDPais
		,UPPER(cp.Codigo) AS Codigo
		,UPPER(cp.Descripcion) AS Descripcion
		,UPPER(cp.FormatoCodigoPostal) AS FormatoCodigoPostal
		,UPPER(cp.FormatoRegistroIdentidadTributaria) AS FormatoRegistroIdentidadTributaria
		,UPPER(cp.Agrupaciones) AS Agrupaciones
	into #tempPaises
	From [Sat].[tblCatPaises] cp
	where (cp.IDPais = @IDPais or isnull(@IDPais, 0) = 0) 
		and	(@query = '""' or contains(cp.*, @query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempPaises

	select @TotalRegistros = count(IDPais) from #tempPaises

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempPaises
	order by
		case when @orderByColumn = 'Codigo'	and @orderDirection = 'asc'	then Codigo end,			
		--case when @orderByColumn = 'Codigo'	and @orderDirection = 'desc'then Codigo end desc,
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	then Descripcion end,			
		--case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'then Descripcion end desc,
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
