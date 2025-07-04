USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-02-21			Justin Davila		Se agregó el parámetro @IDGenero para buscar artículos segun
										su genero o son indistintos al genero
2024-02-22			Justin Davia		Corregimos el valor de salida de la columna TotalRegistros
										agregando un where para las variables @TotalPaginas y 
										@TotalRegistros
2024-03-08			Justin Davila		Correccion de origen del campo Costo
***************************************************************************************************/
CREATE   proc [ControlEquipos].[spBuscarArticulosAsignables](
	@IDArticulo int,
    @IDTipoArticulo int = null,
	@IDUsuario int,
	@IDGenero char(1),
	@PageNumber INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(4000) = '""',
	@orderByColumn VARCHAR(50) = 'Nombre',
	@orderDirection VARCHAR(4) = 'asc'

)
as
begin
	SET FMTONLY OFF;
	DECLARE 
		@IDIdioma varchar(20),
		@Empleado VARCHAR(40)
	;
	DECLARE 
            @ID_CAT_ESTATUS_ARTICULO_STOCK INT = 1,
            @ID_CAT_ESTATUS_ARTICULO_ASIGNADO INT = 2,
			@ID_CAT_ESTATUS_ARTICULO_DEFECTUOSO_DAÑADO int = 4,
			@ID_CAT_ESTATUS_ARTICULO_INSPECCION int = 5,
            @ID_CAT_ESTATUS_ARTICULO_DEVUELTO int = 6,
			@ID_CAT_ESTATUS_ARTICULO_OBSOLETO int = 7,
			@ID_CAT_ESTATUS_ARTICULO_BLOQUEADO_RESTRINGIDO int = 9,
			@ID_CAT_ESTATUS_ARTICULO_REPARACION_MANTENIMIENTO int = 10,
			@ID_CAT_ESTATUS_ARTICULO_PERDIDO_ROBADO int = 11,
			@ID_CAT_ESTATUS_ARTICULO_CUARENTENA int = 12
	
    
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
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
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	IF OBJECT_ID('tempdb..#TempArticulosAsignables') IS NOT NULL DROP TABLE #TempArticulosAsignables;
    IF OBJECT_ID('tempdb..#TempLastEstatusArticulos') IS NOT NULL DROP TABLE #TempLastEstatusArticulos; 

    WITH CTE AS (
        SELECT
            [IDEstatusArticulo],
            [IDCatEstatusArticulo],
            [FechaHora],
            [Empleados],
            [IDUsuario],
            [IDDetalleArticulo],
            ROW_NUMBER() OVER (PARTITION BY IDDetalleArticulo ORDER BY FechaHora desc) AS RowNum
        FROM
            ControlEquipos.tblEstatusArticulos
    )
    select [IDEstatusArticulo],
            [IDCatEstatusArticulo],
            [FechaHora],
            [Empleados],
            [IDUsuario],
            cte.[IDDetalleArticulo],
            UsoCompartido,
            RowNum
        into #TempLastEstatusArticulos  
    from CTE
    inner join ControlEquipos.tblDetalleArticulos  da on CTE.IDDetalleArticulo = da.IDDetalleArticulo
    inner join ControlEquipos.tblArticulos a on a.IDArticulo=da.IDArticulo
    where RowNum=1 
     and ((cte.IDCatEstatusArticulo in (@ID_CAT_ESTATUS_ARTICULO_STOCK,@ID_CAT_ESTATUS_ARTICULO_DEVUELTO)) or (cte.IDCatEstatusArticulo in (@ID_CAT_ESTATUS_ARTICULO_ASIGNADO) and a.UsoCompartido=1))


    -- select * from  #TempLastEstatusArticulos  

	select daa.IDDetalleArticulo,
		ISNULL(ea.IDEstatusArticulo,0) as IDEstatusArticulo,
		ISNULL(ea.IDCatEstatusArticulo, 0) as IDCatEstatusArticulo,
		daa.IDArticulo,
		UPPER(daa.Etiqueta) as Etiqueta,
		a.IDTipoArticulo,
        a.TieneCaducidad,
        a.UsoCompartido,
        ISNULL(CAST(daa.IDGenero as varchar(3)), 'N/A') as IDGenero,
        ISNULL(JSON_VALUE(gn.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'N/A') as Genero,
		JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoArticulo,
		a.Nombre,
		a.Descripcion,
		ISNULL(daa.Costo, 0.00) as Costo,
		a.Cantidad,
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
		  ) as Propiedades
	into #TempArticulosAsignables
	  from #TempLastEstatusArticulos ea
	  inner join ControlEquipos.tblDetalleArticulos daa on daa.IDDetalleArticulo = ea.IDDetalleArticulo
	  inner join ControlEquipos.tblArticulos a on a.IDArticulo = daa.IDArticulo
      left join rh.tblCatGeneros gn on gn.IDGenero = daa.IDGenero
	  inner join ControlEquipos.tblCatTiposArticulos ta on ta.IDTipoArticulo = a.IDTipoArticulo
	  where 
        (daa.IDArticulo = @IDArticulo /*or (isnull(@IDArticulo,0)=0)*/)  and 
	--   (ea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_ASIGNADO or ISNULL(ea.IDCatEstatusArticulo,0) = 0) and
	--   (ea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_BLOQUEADO_RESTRINGIDO or ISNULL(ea.IDCatEstatusArticulo,0) = 0) and
	--   (ea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_CUARENTENA or ISNULL(ea.IDCatEstatusArticulo,0) = 0) and
	--   (ea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_DEFECTUOSO_DAÑADO or ISNULL(ea.IDCatEstatusArticulo,0) = 0) and
	--   (ea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_INSPECCION or ISNULL(ea.IDCatEstatusArticulo,0) = 0) and
	--   (ea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_OBSOLETO or ISNULL(ea.IDCatEstatusArticulo,0) = 0) and
	--   (ea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_PERDIDO_ROBADO or ISNULL(ea.IDCatEstatusArticulo,0) = 0) and
	--   (ea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_REPARACION_MANTENIMIENTO or ISNULL(ea.IDCatEstatusArticulo,0) = 0) and 
	  (@query = '""' or contains(daa.*, @query))

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempArticulosAsignables
	where IDGenero = @IDGenero or IDGenero = 'N/A'

	select @TotalRegistros = count(IDDetalleArticulo) from #TempArticulosAsignables
	where IDGenero = @IDGenero or IDGenero = 'N/A'

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempArticulosAsignables a
	where a.IDGenero = @IDGenero or a.IDGenero = 'N/A'
	order by
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'asc'	then a.Nombre end,			
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'desc'then a.Nombre end desc,
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	then a.Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'then a.Descripcion end desc,
		a.Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end

/**
exec ControlEquipos.spBuscarArticulosAsignables
	@IDArticulo = 225,
	@IDUsuario = 1


**/
GO
