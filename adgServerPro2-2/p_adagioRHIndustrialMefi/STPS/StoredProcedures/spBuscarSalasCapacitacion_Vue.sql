USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [STPS].[spBuscarSalasCapacitacion_Vue](
	@IDSalaCapacitacion int = null
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
			else '"' + @query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempSalasCapacitacion') is not null drop table #tempSalasCapacitacion;

	SELECT 
		SC.IDSalaCapacitacion
		,SC.Nombre
		,isnull(SC.Ubicacion,'') as Ubicacion
		,isnull(SC.Capacidad,0) as  Capacidad
		,ROW_NUMBER() OVER(Order by SC.IDSalaCapacitacion asc) as ROWNUMBER
	into #tempSalasCapacitacion
	FROM STPS.tblSalasCapacitacion SC with (nolock)
	where (IDSalaCapacitacion = @IDSalaCapacitacion) OR (ISNULL(@IDSalaCapacitacion,0) = 0)
	and (@query = '""' or contains(SC.*, @query))

	select @TotalPaginas =CEILING(cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempSalasCapacitacion

	select @TotalRegistros = count(IDSalaCapacitacion) from #tempSalasCapacitacion

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempSalasCapacitacion
	order by
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'asc'	then Nombre end,
		case when @orderByColumn = 'Ubicacion'	and @orderDirection = 'asc'	then Nombre end,
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
