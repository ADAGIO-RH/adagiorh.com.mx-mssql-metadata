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
CREATE PROC [Transporte].[spBuscarRutas] 
(
    @IDUsuario	int = 0      
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY              
    /*
    @IDRuta	int = null  
    ,@ClaveRuta varchar(20)=null
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveRuta'
	,@orderDirection varchar(4) = 'asc'*/
) as

	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00       	
       , @PageNumber	int = 1
       , @PageSize		int = 2147483647
	    ,@query			varchar(100) = '""'
	    ,@orderByColumn	varchar(50) = 'ClaveRuta'
	    ,@orderDirection varchar(4) = 'asc'
	;
	
    Select  @PageNumber=isnull(Value,1) from @dtFiltros where Catalogo = 'PageNumber'
    Select  @PageSize=isnull(Value,2147483647) from @dtFiltros where Catalogo = 'PageSize'
    Select  @query=isnull(Value,'""') from @dtFiltros where Catalogo = 'query'
    Select  @orderByColumn=isnull(Value,'CodigoVehiculo') from @dtFiltros where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtFiltros where Catalogo = 'orderDirection'
 


				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end


	declare @tempResponse as table (
                [IDRuta] INT ,                
                [ClaveRuta] varchar (20) NOT NULL,                
                [Descripcion] varchar (100) NOT NULL,                
                [Origen] varchar (100) NOT NULL,
                [Destino] varchar (100) NOT NULL,
                [KMRuta] int not null,                                                
                [NumeroParadas] INT,
                [Status] INT
    );

    INSERT @tempResponse    
    select 
    v.IDRuta,
    v.ClaveRuta,
    v.Descripcion,
    v.Origen,
    v.Destino,
    v.KMRuta,        
    count(vd.IDRuta),
    V.Status
    
            
    from Transporte.tblCatRutas AS V
    left join Transporte.tblCatRutasDetalle vd on vd.IDRuta=v.IDRuta
    where   (@query = '""' or V.Descripcion like '%'+@query+'%' or V.ClaveRuta like '%'+@query+'%')  
    AND ((V.IDRuta in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRuta'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDRuta' and (isnull(Value,'')<>'' and Value<>0 )))))               
    AND ((V.ClaveRuta in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveRuta'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClaveRuta' and (isnull(Value,'')<>'' )))))                   
    and ((V.Status in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Status'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Status' and (isnull(Value,'')<>''  )))))     
    group by v.IDRuta,
    v.ClaveRuta,
    v.Descripcion,
    v.Origen,
    v.Destino,
    v.KMRuta,        
    V.Status     
    order by V.Descripcion


    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDRuta) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'ClaveRuta'			and @orderDirection = 'asc'		then ClaveRuta end,			
		case when @orderByColumn = 'ClaveRuta'			and @orderDirection = 'desc'	then ClaveRuta end desc,					
		ClaveRuta asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
