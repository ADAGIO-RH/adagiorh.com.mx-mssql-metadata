USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-07
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROC [Transporte].[spBuscarRutasPersonal] 
(
    @IDUsuario	int = 0      
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY              
    /*
     @IDRutaPersonal	int = null
    ,@IDEmpleado int =null
    ,@FechaIni date =null
    ,@FechaFin  date =null
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'IDRutaPersonal'
	,@orderDirection varchar(4) = 'asc'*/

) as

	SET FMTONLY OFF;

	SET FMTONLY OFF;
		declare  
	    @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
       ,@PageNumber	int =1
       ,@PageSize		int = 2147483647
	    ,@query			varchar(100) = '""'
	    ,@orderByColumn	varchar(50) = 'IDRutaPersonal'
	    ,@orderDirection varchar(4) = 'desc'
        , @FechaIni date
        , @FechaFin date
 
      
    Select  @PageNumber=isnull(Value,1) from @dtFiltros where Catalogo = 'PageNumber'
    Select  @PageSize=isnull(Value,2147483647) from @dtFiltros where Catalogo = 'PageSize'
    Select  @query=isnull(Value,'""') from @dtFiltros where Catalogo = 'query'
    Select  @orderByColumn=isnull(Value,'IDRutaPersonal') from @dtFiltros where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'desc') from @dtFiltros where Catalogo = 'orderDirection'

    select  @FechaIni=isnull(Value,null) from @dtFiltros where Catalogo = 'FechaIni'
    select  @FechaFin=isnull(Value,null) from @dtFiltros where Catalogo = 'FechaFin'
 

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
                [IDRutaPersonal] INT ,
                [IDEmpleado]  INT ,
                [Nombres] VARCHAR (50),
                [Apellidos] VARCHAR (50),
                [FechaInicio] date,
                [FechaFin] date,
                [IDRuta1] int,
                [ClaveRuta1] VARCHAR (20),
                [IDRutaHorario1] int,
                [HoraLlegada1] time,
                [HoraSalida1] time,
              [DescripcionRuta1] VARCHAR (100),
                [IDRuta2] int,
                [ClaveRuta2] VARCHAR (20),
                [IDRutaHorario2] int,
                [HoraLlegada2] time,
                [HoraSalida2] time,
               [DescripcionRuta2] VARCHAR (100)
    );

    INSERT @tempResponse    
    select
        rv.IDRutaPersonal,
        rv.IDEmpleado,
        rv.Nombres,
        RV.Apellidos,
        rv.FechaInicio,
        rv.FechaFin,
        r1.IDRuta,
        r1.ClaveRuta,
        isnull(rh1.IDRutaHorario,0),
        isnull(rh1.HoraLlegada,'00:00:00'),
        isnull(rh1.HoraSalida,'00:00:00'),
        r1.Descripcion,
        r2.IDRuta,
        r2.ClaveRuta,
        isnull(rh2.IDRutaHorario,0),
        isnull(rh2.HoraLlegada,'00:00:00'),
        isnull(rh2.HoraSalida,'00:00:00'),
        r2.Descripcion
    from Transporte.tblRutasPersonal rv
    inner join Transporte.tblCatRutas r1 on r1.IDRuta=rv.IDRuta1
    left join Transporte.tblCatRutasHorarios rh1 on  rh1.IDRutaHorario=rv.IDRutaHorario1
    inner join Transporte.tblCatRutas r2 on r2.IDRuta= rv.IDRuta2    
    left join Transporte.tblCatRutasHorarios rh2 on  rh2.IDRutaHorario=rv.IDRutaHorario2
    where (rv.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDEmpleado'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDEmpleado' and (isnull(Value,'')<>''  )))) 
            and (   rv.FechaInicio BETWEEN @FechaIni and @FechaFin  )              
            and ( 
                    (rv.IDRuta1 in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRuta'),','))               
                    or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDRuta' and (isnull(Value,'')<>''   )))) OR
                    (rv.IDRuta2 in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRuta'),','))               
                    or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDRuta' and (isnull(Value,'')<>''   ))))
                    
                )     
       
    order by rv.FechaFin



    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDRutaPersonal) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'FechaFin'			and @orderDirection = 'asc'		then FechaFin end,			
		case when @orderByColumn = 'FechaFin'			and @orderDirection = 'desc'	then FechaFin end desc,					
		FechaFin asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
