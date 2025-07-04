USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ELE].[spBuscarServicioEmpleado](    
	@IDServicioEmpleado int = null   
    ,@IDEmpleado int = null   
    ,@IDTipoServicio int=null
    ,@Catalogo varchar(100) = null
    ,@FechaFin date=null
    ,@FechaInicio date=null
	,@IDUsuario int = null  
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Fecha'
	,@orderDirection varchar(4) = 'asc'    
)    
AS    
BEGIN    
	SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Fecha' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	
	IF OBJECT_ID('tempdb..#TempTipoServicios') IS NOT NULL DROP TABLE #TempTiposServicios
    	
  
	-- set @query = case 
	-- 				when @query is null then '""' 
	-- 				when @query = '' then '""'
	-- 				when @query = '""' then '""'
	-- 			else '"'+@query + '*"' end
            --  'Areas',
            --         'CentrosCostos',
            --         'ClasificacionesCorporativas',                    
            --         'Departamentos',
            --         'Divisiones',                                                            
            --         'Puestos',                    
            --         'Regiones',                                        
            --         'Sucursales'

            
	SELECT     
		c.IDServicioEmpleado,
        c.IDEmpleado ,        
        c.IDTipoServicio,        
        cat.Descripcion as [TipoServicio],
        c.Catalogo,
        c.IDCatalogo,
        catalogo.DescripcionCatalogo,
        c.Descripcion,
        c.Fecha,
        c.TiempoDecimal,
        c.TiempoFecha        
	into #TempTiposServicios
	FROM ELE.[tblServicioEmpleados] C  with(nolock)   		 
    inner join ele.tblCatTiposServicios  cat on c.IDTipoServicio=cat.IDTipoServicio
    left join (
        select IDArea as IDCatalogo,'Areas' as Catalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatArea with(nolock)
        union all 
        select IDCentroCosto as IDCatalogo,'CentrosCostos' as Catalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatCentroCosto with(nolock)
		union all
        select IDClasificacionCorporativa as IDCatalogo,'ClasificacionesCorporativas' as Catalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatClasificacionesCorporativas with(nolock)
		union all        
        select IDDepartamento as IDCatalogo,'Departamentos' as Catalogo,  UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatDepartamentos with(nolock)                
        union all                 
        select IDDivision as IDCatalogo,'Divisiones' as Catalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatDivisiones with(nolock)
        union all
        select IDPuesto as IDCatalogo,'Puestos' as Catalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatPuestos with(nolock)
		union all 
        select IDRegion as IDCatalogo,'Regiones' as Catalogo, UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) AS DescripcionCatalogo from rh.tblCatRegiones with(nolock)        
		union all
        select IDSucursal as IDCatalogo,'Sucursales' as Catalogo, Descripcion AS DescripcionCatalogo from rh.tblCatSucursales with(nolock)	    		        
    ) as catalogo on catalogo.IDCatalogo=C.IDCatalogo and catalogo.Catalogo=c.Catalogo
    
	WHERE   ((c.IDServicioEmpleado = @IDServicioEmpleado ) OR (isnull(@IDServicioEmpleado,0) = 0)) AND
            ((c.IDEmpleado = @IDEmpleado ) OR (isnull( @IDEmpleado,0) = 0) ) AND
		    ( ISNULL(@query,'') = '' or c.Descripcion like  '%'+@query+'%')  AND 
            (c.IDTipoServicio =@IDTipoServicio or isnull(@IDTipoServicio,0)=0) AND 
            (c.Catalogo =@Catalogo or isnull(@Catalogo,'')='')  AND
            (( @FechaFin is null or @FechaInicio is null ) or (C.Fecha  BETWEEN @FechaInicio and @FechaFin ))
	
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempTiposServicios

	select @TotalRegistros = cast(COUNT([IDTipoServicio]) as decimal(18,2)) from #TempTiposServicios		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,@TotalRegistros as TotalRegistros
	from #TempTiposServicios
	order by 
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'asc'		then Fecha end,			
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'desc'	then Fecha end desc,					
        case when @orderByColumn = 'DescripcionCatalogo'			and @orderDirection = 'asc'		then DescripcionCatalogo end,			
		case when @orderByColumn = 'DescripcionCatalogo'			and @orderDirection = 'desc'	then DescripcionCatalogo end desc,					
        case when @orderByColumn = 'TipoServicio'			and @orderDirection = 'asc'		then TipoServicio end,			
		case when @orderByColumn = 'TipoServicio'			and @orderDirection = 'desc'	then TipoServicio end desc,					
        case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,					
        case when @orderByColumn = 'Catalogo'			and @orderDirection = 'asc'		then Catalogo end,			
		case when @orderByColumn = 'Catalogo'			and @orderDirection = 'desc'	then Catalogo end desc,					
        case when @orderByColumn = 'TiempoFecha'			and @orderDirection = 'asc'		then TiempoFecha end,			
		case when @orderByColumn = 'TiempoFecha'			and @orderDirection = 'desc'	then TiempoFecha end desc,					
        case when @orderByColumn = 'TiempoDecimal'			and @orderDirection = 'asc'		then TiempoDecimal end,			
		case when @orderByColumn = 'TiempoDecimal'			and @orderDirection = 'desc'	then TiempoDecimal end desc,					
		Fecha asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
