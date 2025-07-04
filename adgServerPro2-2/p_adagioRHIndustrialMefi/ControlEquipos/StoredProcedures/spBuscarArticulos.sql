USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [d_adagioRH_1_5_0_2_Uniformes]
--GO
--/****** Object:  StoredProcedure [ControlEquipos].[spBuscarArticulos]    Script Date: 29/08/2023 10:33:29 a. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
CREATE   proc [ControlEquipos].[spBuscarArticulos](
	@IDArticulo int = 0
	, @IDTipoArticulo int = 0
	, @IDUsuario int
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
			else '"'+@query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempArticulos') is not null drop table #tempArticulos;
	if object_id('tempdb..#tempEstatusArticulos') is not null drop table #tempEstatusArticulos;

	select 
		a.IDArticulo,
		a.IDTipoArticulo,
		ISNULL(da.IDDetalleArticulo, 0) as IDDetalleArticulo,
		JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoArticulo,
		ISNULL(a.IDMetodoDepreciacion, 0) as IDMetodoDepreciacion,
		ISNULL(md.Nombre, 'N/A') as MetodoDepreciacion,
		UPPER(a.Nombre) as Nombre,
		UPPER(a.Descripcion) as Descripcion,
		ISNULL(da.Etiqueta, '') as Etiqueta,
		ISNULL(ea.IDEstatusArticulo,0) as IDEstatusArticulo,
		ISNULL(ea.IDCatEstatusArticulo, 0) as IDCatEstatusArticulo,
		ISNULL(cea.Nombre,'No aplica') as EstatusArticulo,
		ISNULL(ea.Empleados, '[]') as Empleados,
		--ISNULL(CAST(a.IDGenero as varchar(3)), 'N/A') as IDGenero,
		--(
		--	select JSON_VALUE(item.Value, '$.' + lower(replace(@IDIdioma, '-','')) + '.Descripcion')
		--	FROM OPENJSON(cg.[Traduccion]) AS item
		--	WHERE cg.IDGenero = a.IDGenero
		--) AS [genero],
		--ISNULL(JSON_VALUE(cg.Traduccion, FORMATMESSAGE('$.%s.%s', '' + lower(replace(@IDIdioma, '-','')) + '', 'Descripcion')), 'N/A') as Genero,
		--JSON_VALUE(cg.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) ,
		--a.Costo,
		a.Cantidad,
		a.UsoCompartido,
		ISNULL(a.Stock, 0) as Stock,
		CAST(ISNULL(a.FechaHoraUltimaActualizaciónStock, '9999-01-01') as date)  FechaHoraUltimaActualizaciónStock,
		--a.TieneCaducidad,
		a.FechaAlta,
		ROW_NUMBER() over(partition by a.IDArticulo order by da.IDDetalleArticulo, ta.IDTipoArticulo) RN
		--(
	 --  	select 
	 --  		JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS [NombrePropiedad],
	 --  		CASE
	 --  		WHEN ISJSON(cp.[Data]) = 1 THEN
	 --  			(
	 --  				SELECT JSON_VALUE(item.Value, '$.Nombre') 
	 --  				FROM OPENJSON(cp.[Data]) AS item
	 --  				WHERE JSON_VALUE(item.Value, '$.ID') = vp.Valor
	 --  			)
	 --  		ELSE
	 --  			vp.Valor -- o cualquier otro valor por defecto que desees cuando [Data] no sea un JSON válido
	 --  	END AS [ValorPropiedad]
	 --  	from [ControlEquipos].[tblCatPropiedades] cp
	 --  		left join [ControlEquipos].[tblValoresPropiedades] vp on vp.IDPropiedad = cp.IDPropiedad
	 --  	where cp.IDTipoArticulo = a.IDTipoArticulo
	 --  	for json auto
	 --  ) as Propiedades
	INTO #tempEstatusArticulos
	from ControlEquipos.tblArticulos a
	left join ControlEquipos.tblMetodoDepreciacion md on md.IDMetodoDepreciacion = a.IDMetodoDepreciacion
	left join ControlEquipos.tblDetalleArticulos da on da.IDArticulo = a.IDArticulo
	left join ControlEquipos.tblCatTiposArticulos ta on ta.IDTipoArticulo = a.IDTipoArticulo
	left join ControlEquipos.tblEstatusArticulos ea on ea.IDDetalleArticulo = da.IDDetalleArticulo
	left join ControlEquipos.tblCatEstatusArticulos cea on cea.IDCatEstatusArticulo = ea.IDCatEstatusArticulo
	--left join RH.tblCatGeneros cg on cg.IDGenero = a.IDGenero
	where 
		(a.IDTipoArticulo = @IDTipoArticulo or isnull(@IDTipoArticulo, 0) = 0)  
		and (a.IDArticulo = @IDArticulo or isnull(@IDArticulo, 0) = 0)
			and (@query = '""' or contains(a.*, @query))
	
	select *
	into #tempArticulos
	from #tempEstatusArticulos
	where RN = 1
	--order by ea.FechaHora desc

	
	--select 
	--	a.IDArticulo,
	--	a.IDTipoArticulo,
	--	A.IDMetodoDepreciacion,
	--	md.Nombre as MetodoDepreciacion,
	--	ISNULL(da.Etiqueta, 'Artículo consumible') as Etiqueta,
	--	a.Nombre,
	--	JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoArticulo,
	--	a.Descripcion,
	--	a.Costo,
	--	a.TieneCaducidad,
	--	a.FechaAlta,
	--	CAST(ISNULL(da.FechaCaducidad, '9999-01-01') as date)  FechaCaducidad,
	--	ISNULL(a.IDEstatusArticulo, 0) as IDEstatusArticulo,
	--	ISNULL(a.IDCatEstatusArticulo, 0) as IDCatEstatusArticulo,
	--	cea.Nombre as EstatusArticulo,
	--	a.UsoCompartido,
	--	ISNULL(a.Propiedades, '[{}]') as Propiedades
	--into #tempArticulos
	--from #tempEstatusArticulos a
	--	left join [ControlEquipos].[tblCatTiposArticulos] ta on ta.IDTipoArticulo = a.IDTipoArticulo
	--	left join [ControlEquipos].tblMetodoDepreciacion md on md.IDMetodoDepreciacion = a.IDMetodoDepreciacion
	--	left join [ControlEquipos].tblCatEstatusArticulos cea on cea.IDCatEstatusArticulo = a.IDCatEstatusArticulo
	--	left join [ControlEquipos].[tblDetalleArticulos] da on da.IDArticulo = a.IDArticulo


	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempArticulos

	select @TotalRegistros = count(IDArticulo) from #tempArticulos

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempArticulos
	order by
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'asc'	then Nombre end,			
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'desc'then Nombre end desc,
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'then Descripcion end desc,
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end



/**
exec [ControlEquipos].[spBuscarArticulos]
	@IDArticulo = 0
	, @IDUsuario = 1
	--, @PageNumber = 1
	--, @PageSize = 2
	, @query = 'MacBook'
	, @orderByColumn  = 'Nombre'
	, @orderDirection = 'asc'


select * from [ControlEquipos].[tblCatTiposArticulos]
select * from [ControlEquipos].[tblCatPropiedades]




*/
GO
