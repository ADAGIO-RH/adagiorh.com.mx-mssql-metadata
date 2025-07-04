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
CREATE PROC [Transporte].[spBuscarRutaHorarios] 
(
     @IDUsuario int
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY              
) as

	SET FMTONLY OFF;

    SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00       	
       , @PageNumber	int = 1
       , @PageSize		int = 2147483647
	    ,@query			varchar(100) = '""'
	    ,@orderByColumn	varchar(50) = 'HoraSalida'
	    ,@orderDirection varchar(4) = 'asc'
        ,@HoraSalida  time
        ,@HoraLlegada  time
	;
	
    Select  @PageNumber=isnull(Value,1) from @dtFiltros where Catalogo = 'PageNumber'
    Select  @PageSize=isnull(Value,2147483647) from @dtFiltros where Catalogo = 'PageSize'
    Select  @query=isnull(Value,'""') from @dtFiltros where Catalogo = 'query'
    Select  @orderByColumn=isnull(Value,'HoraSalida') from @dtFiltros where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtFiltros where Catalogo = 'orderDirection'

    Select  @HoraSalida=Value from @dtFiltros where Catalogo = 'HoraSalida'
    Select  @HoraLlegada=Value  from @dtFiltros where Catalogo = 'HoraLlegada'
 
    
 
				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end


	declare @tempResponse as table (
                [IDRutaHorario] INT ,                
                [IDRuta] int ,
                [HoraSalida] time,   
                [HoraLlegada] time,
                [Status] int              
    );

    INSERT @tempResponse    
    select * from  Transporte.tblCatRutasHorarios rh
    WHERE ((rh.IDRutaHorario in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRutaHorario'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDRutaHorario' and (isnull(Value,'')<>'' and Value<>0 )))))               
        and ((rh.IDRuta in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRuta'),','))               
            or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDRuta' and (isnull(Value,'')<>'' and Value<>0 )))))     
        and ( (@HoraSalida is not null and @HoraLlegada  is not null and rh.HoraSalida = @HoraSalida and rh.HoraLlegada=@HoraLlegada) or 
              (@HoraSalida is  null and @HoraLlegada  is null))
    
    
    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDRuta) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'HoraSalida'			and @orderDirection = 'asc'		then HoraSalida end,			
		case when @orderByColumn = 'HoraSalida'			and @orderDirection = 'desc'	then HoraSalida end desc,					
		HoraSalida asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

    
    /*	
     select * from  Transporte.tblCatRutasHorarios rh
     where  (rh.IDRuta = @IDRuta OR @IDRuta IS NUll or @IDRuta=0) and (rh.IDRutaHorario = @IDRutaHorario OR @IDRutaHorario IS NUll or @IDRutaHorario=0) 
*/
    select 
    rh.IDRutaHorario,rh.IDHorario,h.Codigo,h.Descripcion,h.HoraEntrada,h.HoraSalida
    from Transporte.tblCatRutasHorariosDetalle rh
    inner join Asistencia.tblCatHorarios h on h.IDHorario=rh.IDHorario
    where   IDRutaHorario in (select IDRutaHorario from @tempResponse)
    order by h.HoraEntrada
GO
