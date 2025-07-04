USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBuscarDetallesArticulos](
	@IDArticulo int
	, @IDUsuario int
	, @IDDetalleArticulo int = 0
	, @PageNumber INT = 1
	, @PageSize INT = 2147483647
	, @query VARCHAR(4000) = '""'
	, @orderByColumn VARCHAR(50) = 'IDDetalleArticulo'
	, @orderDirection VARCHAR(4) = 'asc'
)
as
begin
	SET FMTONLY OFF;
	DECLARE 
		@IDIdioma varchar(20),
		@TotalPaginas int = 0,
	   @TotalRegistros int
	;
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'IDDetalleArticulo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end

	if object_id('tempdb..#tempDetallesArticulos') is not null drop table #tempDetallesArticulos;
	if object_id('tempdb..#tempRN') is not null drop table #tempRN;

	select
		daa.IDDetalleArticulo,
		daa.IDArticulo,
		UPPER(daa.Etiqueta) as Etiqueta,
		daa.FechaAlta,
		ea.IDEstatusArticulo,
		(
	   		select 
	   			JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS [NombrePropiedad],
	   			CASE
	   			WHEN ISJSON(cp.[Data]) = 1 THEN
	   				(
	   					SELECT JSON_VALUE(item.Value, '$.Nombre') 
	   					FROM OPENJSON(cp.[Data]) AS item
	   					WHERE JSON_VALUE(item.Value, '$.ID') = vp.Valor
	   				)
	   			ELSE
	   				isnull(vp.Valor,'') -- o cualquier otro valor por defecto que desees cuando [Data] no sea un JSON válido
	   			END AS [ValorPropiedad]
	   		from ControlEquipos.tblDetalleArticulos da
				inner join ControlEquipos.tblArticulos a on a.IDArticulo = da.IDArticulo
				inner join ControlEquipos.tblCatTiposArticulos ta on ta.IDTipoArticulo = a.IDTipoArticulo
				inner join ControlEquipos.tblCatPropiedades cp on cp.IDTipoArticulo = ta.IDTipoArticulo
				left join ControlEquipos.tblValoresPropiedades vp on vp.IDPropiedad = cp.IDPropiedad and vp.IDDetalleArticulo = da.IDDetalleArticulo
			where daa.IDDetalleArticulo = da.IDDetalleArticulo
	   		for json auto
		  ) as Propiedades,
		ea.IDCatEstatusArticulo,
		ISNULL(DDA.IDUrlDocumentos, 0) as IDUrlDocumentos,
		ISNULL(DDA.[Url], '') as [Url],
		ISNUlL(DDA.NombreDocumento, '') as NombreDocumento,
		ROW_NUMBER() over(partition by daa.IDDetalleArticulo order by ea.IDEstatusArticulo desc) as RN
	into #tempDetallesArticulos
	from ControlEquipos.tblDetalleArticulos daa
		inner join ControlEquipos.tblEstatusArticulos ea on ea.IDDetalleArticulo = daa.IDDetalleArticulo
		left join ControlEquipos.tblUrlsDocumentosDetallesArticulos DDA on DDA.IDDetalleArticulo = daa.IDDetalleArticulo
	where daa.IDArticulo = @IDArticulo
		and (daa.IDDetalleArticulo = @IDDetalleArticulo or isnull(@IDDetalleArticulo, 0) = 0)
		and (@query = '""' or contains(daa.*, @query))
	
	select * 
	into #tempRN
	from #tempDetallesArticulos
	where RN = 1

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempRN

	select @TotalRegistros = count(IDDetalleArticulo) from #tempRN

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempRN
	order by
		case when @orderByColumn = 'IDDetalleArticulo'	and @orderDirection = 'asc'	then IDDetalleArticulo end,			
		case when @orderByColumn = 'IDDetalleArticulo'	and @orderDirection = 'desc'then IDDetalleArticulo end desc,
		Etiqueta asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
