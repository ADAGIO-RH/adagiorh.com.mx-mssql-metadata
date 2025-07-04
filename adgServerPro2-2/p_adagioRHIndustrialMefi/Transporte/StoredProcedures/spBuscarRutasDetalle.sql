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
CREATE PROC [Transporte].[spBuscarRutasDetalle] 
(
    @IDRuta	int = null,    
    @IDRutaDetalle int = null,
    @PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Orden'
	,@orderDirection varchar(4) = 'asc'
) as

	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end


	declare @tempResponse as table (
                [IDRutaDetalle] INT ,                
                [IDRuta] INT ,                
                [Orden] int not null,                
                [Parada] varchar (100) NOT NULL               
    );

    INSERT @tempResponse    
    select 
    v.IDRutaDetalle,
    v.IDRuta,
    v.Orden,
    v.Parada    
    from Transporte.tblCatRutasDetalle AS V    
    where (V.IDRuta = @IDRuta OR @IDRuta IS NUll or @IDRuta=0) and (@query = '""' or V.Parada like '%'+@query+'%') and (V.IDRutaDetalle = IDRutaDetalle OR IDRutaDetalle IS NUll or IDRutaDetalle=0)    
    order by V.Orden


    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDRutaDetalle) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Orden'			and @orderDirection = 'asc'		then Orden end,			
		case when @orderByColumn = 'Orden'			and @orderDirection = 'desc'	then Orden end desc,					
		Orden asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
