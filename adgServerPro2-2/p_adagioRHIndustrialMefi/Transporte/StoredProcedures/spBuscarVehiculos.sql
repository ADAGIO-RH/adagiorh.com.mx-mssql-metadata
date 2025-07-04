USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-14
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROC [Transporte].[spBuscarVehiculos] 
(
    @IDUsuario	int = 0      
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY              
    
) as

	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
       , @PageNumber	int = 1
       ,@PageSize		int = 2147483647
	    ,@query			varchar(100) = '""'
	    ,@orderByColumn	varchar(50) = 'CodigoVehiculo'
	    ,@orderDirection varchar(4) = 'asc'
               
	    

    
    Select  @PageNumber=isnull(Value,1) from @dtFiltros where Catalogo = 'PageNumber'
    Select  @PageSize=isnull(Value,2147483647) from @dtFiltros where Catalogo = 'PageSize'
    Select  @query=isnull(Value,'""') from @dtFiltros where Catalogo = 'query'
    Select  @orderByColumn=isnull(Value,'CodigoVehiculo') from @dtFiltros where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtFiltros where Catalogo = 'orderDirection'
 


	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end


	declare @tempResponse as table (
                [IDVehiculo] INT ,
                [ClaveVehiculo]  VARCHAR (20),                
                [NumeroEconomico] int ,
                [IDMarcaVehiculo]       INT,
                [DescripcionMarcaVehiculo]  VARCHAR (100),
                [IDTipoCosto]       INT,
                [DescripcionTipoCosto]  VARCHAR (100),
                [IDTipoVehiculo]       INT,
                [DescripcionTipoVehiculo]  VARCHAR (100),
                [IDTipoCombustible]    INT,
                [DescripcionTipoCombustible]  VARCHAR (100),
                [CostoUnidad] DECIMAL (10,2),
                [CantidadPasajeros]    INT,
                [Status] int
    );

    INSERT @tempResponse    
    select 
    v.IDVehiculo,
    v.ClaveVehiculo,    
    v.NumeroEconomico,
    cm.IDMarcaVehiculo,
    cm.Descripcion,

    ccc.IDTipoCosto,
    ccc.Descripcion,

    ctv.IDTipoVehiculo,
    ctv.Descripcion,
    
    ctc.IDTipoCombustible,
    ctc.Descripcion,
    v.CostoUnidad,
    v.CantidadPasajeros,
    v.Status    
    from Transporte.tblCatVehiculos AS v
    inner join Transporte.tblCatTipoCombustible ctc on ctc.IDTipoCombustible=v.IDTipoCombustible
    inner join Transporte.tblCatTipoVehiculo ctv on ctv.IDTipoVehiculo=v.IDTipoVehiculo
    inner join Transporte.tblCatTipoCosto ccc on ccc.IDTipoCosto=v.IDTipoCosto
    inner join Transporte.tblCatMarcaVehiculos cm on cm.IDMarcaVehiculo=v.IDMarcaVehiculo

     

    where ((V.IDVehiculo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDVehiculo'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDVehiculo' and (isnull(Value,'')<>'' and Value<>0 )))))               
    and ((V.IDTipoVehiculo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoVehiculo'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoVehiculo' and (isnull(Value,'')<>'' and Value<>0 )))))     
    and ((V.IDTipoCombustible in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoCombustible'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoCombustible' and (isnull(Value,'')<>'' and Value<>0 )))))     
    and ((V.IDTipoCosto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoCosto'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoCosto' and (isnull(Value,'')<>'' and Value<>0 )))))     
    and ((V.IDMarcaVehiculo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'MarcaVehiculo'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'MarcaVehiculo' and (isnull(Value,'')<>'' and Value<>0 )))))     
    and ((V.Status in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Status'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Status' and (isnull(Value,'')<>''   )))))     
    and (@query = '""' or v.ClaveVehiculo like '%'+@query+'%' or v.NumeroEconomico like '%'+@query+'%')  
    order by v.ClaveVehiculo



    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDVehiculo) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'ClaveVehiculo'			and @orderDirection = 'asc'		then ClaveVehiculo end,			
		case when @orderByColumn = 'ClaveVehiculo'			and @orderDirection = 'desc'	then ClaveVehiculo end desc,					
		ClaveVehiculo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
