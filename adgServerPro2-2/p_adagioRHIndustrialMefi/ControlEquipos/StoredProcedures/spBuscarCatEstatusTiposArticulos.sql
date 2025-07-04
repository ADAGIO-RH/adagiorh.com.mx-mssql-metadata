USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ControlEquipos].[spBuscarCatEstatusTiposArticulos]
	(
		@IDCatEstatusTipoArticulo int = 0,
		@IDUsuario int,
		@PageNumber	int = 1,
		@PageSize		int = 2147483647,
		@query		varchar(5000) = '""',
		@orderByColumn	varchar(50) = 'Nombre',
		@orderDirection varchar(4) = 'asc'
	)
as
begin
	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int,
	   @IDIdioma varchar(20)
	;

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	set @query = 
	case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query =  '""' then '""'
	else @query end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempCatEstatusArticulos') is not null drop table #tempCatEstatusArticulos;

	select ceta.IDCatEstatusTipoArticulo,
		   ceta.Nombre,
		   ceta.Descripcion
	into #tempCatEstatusArticulos
	from ControlEquipos.tblCatEstatusTiposArticulos ceta
	where([ceta].[IDCatEstatusTipoArticulo] = @IDCatEstatusTipoArticulo
		or isnull(@IDCatEstatusTipoArticulo,0) = 0)
		--and (@query = '""' or contains([cea].*, @query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatEstatusArticulos

	select @TotalRegistros = count(IDCatEstatusTipoArticulo) from #tempCatEstatusArticulos

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempCatEstatusArticulos
	order by
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'asc'	then Nombre end,			
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'desc'then Nombre end desc,
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
