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
CREATE PROC [Transporte].[spBuscarRutasProgramadas] 
( 
    @IDUsuario	int = 0      
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY  
  
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

    Select  @FechaIni=Value from @dtFiltros where Catalogo = 'FechaIni'
    Select  @FechaFin=Value  from @dtFiltros where Catalogo = 'FechaFin'
 
    set @FechaIni=isnull(@FechaIni,cast('2000-01-01' as date)) 
    set @FechaFin=isnull(@FechaFin,cast('3000-01-01' as date))

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end


	declare @tempResponse as table (              
                [IDRutaProgramada]  INT,                 
                [ClaveRuta] VARCHAR (20),
                [DescripcionRuta] VARCHAR (100),
                [HoraSalida] time ,
                [HoraLlegada] time ,
                [Fecha] date ,
                [StatusDescripcion] VARCHAR (50),
                [Status]  INT ,
                [PersonasAbordo]  INT ,                
                [Capacidad]  INT ,
                [Disponibilidad]  INT ,
                [KMRuta]  INT 
    );

    INSERT @tempResponse (IDRutaProgramada,ClaveRuta,DescripcionRuta,HoraSalida,HoraLlegada,Fecha,PersonasAbordo,KMRuta)   
    select  
               rp.IDRutaProgramada,
        cr.ClaveRuta ,
        cr.Descripcion ,
        rp.HoraSalida,
        rp.HoraLlegada,
        rp.Fecha,        
        count(rpp.IDRutaProgramadaPersonal) as [PersonasAbordo],
        cr.KMRuta        
    From Transporte.tblRutasProgramadas as rp
    inner join Transporte.tblRutasProgramadasPersonal rpp on rpp.IDRutaProgramada=rp.IDRutaProgramada 
    inner join Transporte.tblCatRutas  cr on cr.IDRuta=rp.IDRuta
    where ((rp.IDRutaProgramada in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRutaProgramada'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDRutaProgramada' and (isnull(Value,'')<>''   )))))     
        and ((rp.IDRuta in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRuta'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDRuta' and (isnull(Value,'')<>''   )))))     
        and rp.Fecha BETWEEN @FechaIni and @FechaFin
    and (@query = '""' or cr.ClaveRuta like '%'+@query+'%' )      
    group by 
    rp.IDRutaProgramada,
    cr.ClaveRuta ,
    cr.Descripcion ,
    rp.HoraSalida,
    rp.HoraLlegada,
    rp.Fecha,    
    cr.KMRuta
    order by rp.Fecha

    update t1 set Capacidad=isnull(t.sumPasajero,0)  from @tempResponse t1
    inner join  (
        SELECT  rpv.IDRutaProgramada ,sum(cv.CantidadPasajeros)  sumPasajero
        FROM Transporte.tblRutasProgramadasVehiculos rpv
        left join Transporte.tblCatVehiculos cv on cv.IDVehiculo=rpv.IDVehiculo
        where IDRutaProgramada=IDRutaProgramada
        group by   rpv.IDRutaProgramada                
    ) t on t.IDRutaProgramada=t1.IDRutaProgramada

     


    UPDATE @tempResponse set 
            Capacidad= ISNULL(Capacidad,0)
        ,Disponibilidad= case when Capacidad is null  then 0 when Capacidad>=0 then Capacidad-PersonasAbordo end 
        ,[StatusDescripcion] = case when (Capacidad-PersonasAbordo)  < 0 or Capacidad is null then 'Pendiente por asignar vehículos.' when (Capacidad-PersonasAbordo) >= 0 then 'Vehículos asignado.'  end 
        ,[Status] = case when (Capacidad-PersonasAbordo) < 0 or Capacidad IS NULL then 0 when (Capacidad-PersonasAbordo) >= 0 then 1  end 
    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDRutaProgramada) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse rp
    where ((rp.[Status] in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Status'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Status' and (isnull(Value,'')<>''   )))))     
      
	order by 
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'asc'		then Fecha end,			
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'desc'	then Fecha end desc,					
		Fecha asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
