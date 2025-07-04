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
2024-02-21			Justin Davila		Correccion de relacion de tablas para IDGenero de
										ControlEquipos.tblArticulos a ControlEquipos.tblDetalleArticulos
										Join con RH.tblCatGeneros para descripcion del genero
2024-03-08			Justin Davila		Correccion de origen de campo Costo mas un ISNULL
2024-04-29			Justin Davila		Agregamos campo IDContratoEmpleado para nuevos componentes de carta responsiva
2024-05-24			Justin Davila		Agregamos busqueda por query
***************************************************************************************************/
CREATE  proc [ControlEquipos].[spBuscarDetallesArticulosByIDEmpleado] --@IDEmpleado=17260, @IDUsuario=1
(
	@IDEmpleado int 
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
	DECLARE 
		@IDIdioma varchar(20),
		@TotalPaginas int = 0,
	   @TotalRegistros int       
	;
    DECLARE @ID_CAT_ESTATUS_ARTICULO_ASIGNADO INT = 2;
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

    IF OBJECT_ID('tempdb..#TempLastEstatusArticulos') IS NOT NULL DROP TABLE #TempLastEstatusArticulos;
    IF OBJECT_ID('tempdb..#TempDetallesArticulos') IS NOT NULL DROP TABLE #TempDetallesArticulos;
    IF object_id('tempdb..#TempDetallesArticulosEmpleados') is not null drop table #TempDetallesArticulosEmpleados;

    WITH CTE AS (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY IDDetalleArticulo ORDER BY FechaHora desc) AS RowNum
        FROM
            ControlEquipos.tblEstatusArticulos
    )
    select * 
        into #TempLastEstatusArticulos 
    from CTE where
    -- RowNum=2 and 
     IDCatEstatusArticulo=@ID_CAT_ESTATUS_ARTICULO_ASIGNADO;

    select * into #TempDetallesArticulos
    from #TempLastEstatusArticulos ea
    where @IDEmpleado in (
            select * from OPENJSON(Empleados, '$')
            with (
                IDEmpleado int
            )   
        )

     
    select da.IDArticulo,
	   ta.IDTipoArticulo,
       ea.IDDetalleArticulo,
	   JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS [TipoArticulo],
	   UPPER(Etiqueta) as Etiqueta,
	   a.Nombre,
	   a.Descripcion,
	   ISNULL(da.Costo, 0.00) as Costo,
	   ea.IDEstatusArticulo,
	   ea.IDCatEstatusArticulo,
	   ISNULL(ce.IDContratoEmpleado,0 ) as IDContratoEmpleado,
	   cea.Nombre as Estatus,
	   ea.Empleados,
	   ea.FechaHora,	   
       a.TieneCaducidad,
       a.UsoCompartido,
       ISNULL(cast(da.IDGenero as varchar(3)), 'N/A') as IDGenero,
       ISNULL(JSON_VALUE(cg.Traduccion, FORMATMESSAGE('$.%s.%s', '' + lower(replace(@IDIdioma, '-','')) + '', 'Descripcion')), 'N/A') as Genero,
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
	   			ISNULL(vp.Valor,'') -- o cualquier otro valor por defecto que desees cuando [Data] no sea un JSON válido
	   	END AS [ValorPropiedad]
	   	from [ControlEquipos].[tblCatPropiedades] cp
	   		left join [ControlEquipos].[tblValoresPropiedades] vp on vp.IDPropiedad = cp.IDPropiedad and vp.IDDetalleArticulo = da.IDDetalleArticulo
	   	where cp.IDTipoArticulo = ta.IDTipoArticulo
	   	for json auto
	   ) as Propiedades
        INTO #TempDetallesArticulosEmpleados
       from #TempDetallesArticulos ea 
			inner join  ControlEquipos.tblDetalleArticulos da on da.IDDetalleArticulo=ea.IDDetalleArticulo
			inner join ControlEquipos.tblArticulos a on a.IDArticulo = da.IDArticulo
			inner join [ControlEquipos].[tblCatTiposArticulos] ta on ta.IDTipoArticulo = a.IDTipoArticulo        
			inner join [ControlEquipos].[tblCatEstatusArticulos] cea on cea.IDCatEstatusArticulo = ea.IDCatEstatusArticulo
			left join RH.tblCatGeneros cg on cg.IDGenero = da.IDGenero
			left join RH.tblContratoEmpleado ce on ce.IDReferencia = ea.IDEstatusArticulo
		where (@query = '""' or contains(a.*, @query)) or (@query = '""' or contains(da.*, @query))
	   
 
	
		
    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
    from #TempDetallesArticulosEmpleados

    select @TotalRegistros = count(IDDetalleArticulo) from #TempDetallesArticulosEmpleados

    select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempDetallesArticulosEmpleados
    ORDER BY IDCatEstatusArticulo ASC
	-- order by
	-- 	case when @orderByColumn = 'Etiqueta'	and @orderDirection = 'asc'	then Etiqueta end,			
	-- 	case when @orderByColumn = 'Etiqueta'	and @orderDirection = 'desc'then Etiqueta end desc,
		
	-- 	Etiqueta asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
