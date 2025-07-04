USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-18
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROC [Transporte].[spBuscarRutasProgramadasPersonal] 
(
     @IDUsuario	int = 0      
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY  
    /*@IDRutaProgramadaPersonal	int = null
    ,@IDEmpleado int =null
    ,@FechaIni date =null
    ,@FechaFin  date =null
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'IDRutaProgramadaPersonal'
	,@orderDirection varchar(4) = 'asc'*/
) as

SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
        ,@PageNumber	int = 1
        ,@PageSize		int = 2147483647
	    ,@query			varchar(100) = '""'
	    ,@orderByColumn	varchar(50) = 'Fecha'
	    ,@orderDirection varchar(4) = 'desc'
        ,@FechaIni date
        ,@FechaFin date
	;
 
    Select  @PageNumber=isnull(Value,1) from @dtFiltros where Catalogo = 'PageNumber'
    Select  @PageSize=isnull(Value,2147483647) from @dtFiltros where Catalogo = 'PageSize'
    Select  @query=isnull(Value,'""') from @dtFiltros where Catalogo = 'query'
    Select  @orderByColumn=isnull(Value,'ClaveRuta') from @dtFiltros where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtFiltros where Catalogo = 'orderDirection'
    
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;
	
  
				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end


	declare @tempResponse as table (
                [IDRutaProgramadaPersonal] INT ,
                [IDRutaProgramada] INT ,
                [IDRutaPersonal] INT ,
                [IDEmpleado]  INT ,
                [ClaveEmpleado] VARCHAR (50),
                [Nombres] VARCHAR (50),
                [Apellidos] VARCHAR (50) 
    );

    

    INSERT @tempResponse    
    select
       rv.IDRutaProgramadaPersonal,
       rv.IDRutaProgramada,
       rv.IDRutaProgramadaPersonal,
       p.IDEmpleado,
       isnull(m.ClaveEmpleado,'EXTERNO'),
       p.Nombres,
       p.Apellidos       
    from Transporte.tblRutasProgramadasPersonal rv
    inner join Transporte.tblRutasProgramadas rp on rp.IDRutaProgramada=rv.IDRutaProgramada
    inner join Transporte.tblRutasPersonal p on p.IDRutaPersonal=rv.IDRutaPersonal
    left join rh.tblEmpleadosMaster m on m.IDEmpleado=p.IDEmpleado

    where ((rp.IDRutaProgramada in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRutaProgramada'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDRutaProgramada' and (isnull(Value,'')<>''   )))))     



    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDRutaProgramadaPersonal) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'IDRutaProgramadaPersonal'			and @orderDirection = 'asc'		then IDRutaProgramadaPersonal end,			
		case when @orderByColumn = 'IDRutaProgramadaPersonal'			and @orderDirection = 'desc'	then IDRutaProgramadaPersonal end desc,					
		IDRutaProgramadaPersonal asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
