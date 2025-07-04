USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBuscarCatTiposArticulos](
	@IDTipoArticulo int = null
	, @IDUsuario INT
	, @PageNumber INT = 1
	, @PageSize INT = 2147483647
	, @query VARCHAR(4000) = '""'
	, @orderByColumn VARCHAR(50) = 'Nombre'
	, @orderDirection VARCHAR(4) = 'asc'
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

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"' + @query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempCatTiposArticulos') is not null drop table #tempCatTiposArticulos;

	select 
		cta.IDTipoArticulo,
		UPPER(JSON_VALUE(cta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre'))) as Nombre,
		UPPER(JSON_VALUE(cta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as Descripcion,
		UPPER(cta.Codigo) as Codigo,
		cta.Etiquetar,
		UPPER(ISNULL(cta.PrefijoEtiqueta,'N/A')) as PrefijoEtiqueta,
		cta.Traduccion,
		cta.IDCatEstatusTipoArticulo,
		ceta.Nombre as EstatusTipoArticulo,
		ISNULL(cta.LongitudEtiqueta,0) as LongitudEtiqueta
	into #tempCatTiposArticulos
	from ControlEquipos.tblCatTiposArticulos cta
	inner join ControlEquipos.tblCatEstatusTiposArticulos ceta on ceta.IDCatEstatusTipoArticulo = cta.IDCatEstatusTipoArticulo
	where ((cta.IDTipoArticulo = @IDTipoArticulo OR isnull(@IDTipoArticulo, 0) = 0))
		AND (@query = '""' OR CONTAINS (cta.*, @query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatTiposArticulos

	select @TotalRegistros = count(IDTipoArticulo) from #tempCatTiposArticulos

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempCatTiposArticulos
	order by
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'asc'	then Nombre end,			
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'desc'then Nombre end desc,
		case when @orderByColumn = 'Codigo'	and @orderDirection = 'asc'	then Codigo end,			
		case when @orderByColumn = 'Codigo'	and @orderDirection = 'desc'then Codigo end desc,
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'then Descripcion end desc,
		case when @orderByColumn = 'PrefijoEtiqueta'	and @orderDirection = 'asc'	then PrefijoEtiqueta end,			
		case when @orderByColumn = 'PrefijoEtiqueta'	and @orderDirection = 'desc'then PrefijoEtiqueta end desc,
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end


/*
select * from ControlEquipos.tblCatTiposArticulos
exec [ControlEquipos].[spBuscarCatTiposArticulos]
	@IDTipoArticulo = null
	, @IDUsuario = 1
	, @PageNumber = 1
	, @PageSize = 20
	, @query = 'lap'
	, @orderByColumn VARCHAR(50) = 'Nombre'
	, @orderDirection VARCHAR(4) = 'asc'


*/
GO
