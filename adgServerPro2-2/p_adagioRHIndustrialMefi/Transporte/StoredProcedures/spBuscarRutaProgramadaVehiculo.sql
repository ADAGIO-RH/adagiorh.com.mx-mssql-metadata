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
CREATE PROC [Transporte].[spBuscarRutaProgramadaVehiculo] 
(
    @IDRutaProgramada int = null    
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Apellidos'
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
                [IDRutaProgramadaVehiculo] int,
                [IDRutaProgramada] int,
                [IDVehiculo] int,
                [ClaveVehiculo] VARCHAR(50) ,
                [CantidadPasajeros] int,
                [NumeroEconomico] int,
                [MarcaDescripcion] VARCHAR(100),
                [TipoVehiculoDescripcion] VARCHAR(100),
                [TipoCostoDescripcion] VARCHAR(100),
                [CostoUnidad]  decimal (10,2)
    );

    INSERT @tempResponse    
    
    select 
        rpv.IDRutaProgramadaVehiculo,
        rpv.IDRutaProgramada,
        v.IDVehiculo,
        v.ClaveVehiculo,
        v.CantidadPasajeros,  
        v.NumeroEconomico,
        mv.Descripcion,
        tv.Descripcion,
        tc.Descripcion,
        v.CostoUnidad

    FROM  Transporte.tblRutasProgramadasVehiculos rpv
    inner join Transporte.tblCatVehiculos v on rpv.IDVehiculo=v.IDVehiculo
    inner join Transporte.tblCatMarcaVehiculos mv on mv.IDMarcaVehiculo=v.IDMarcaVehiculo    
    inner join Transporte.tblCatTipoVehiculo tv on tv.IDTipoVehiculo=v.IDTipoVehiculo
    inner join Transporte.tblCatTipoCosto tc on tc.IDTipoCosto=v.IDTipoCosto
    where rpv.IDRutaProgramada=@IDRutaProgramada
    order by v.NumeroEconomico



    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDRutaProgramadaVehiculo) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'NumeroEconomico'			and @orderDirection = 'asc'		then IDRutaProgramadaVehiculo end,			
		case when @orderByColumn = 'NumeroEconomico'			and @orderDirection = 'desc'	then IDRutaProgramadaVehiculo end desc,					
		IDRutaProgramadaVehiculo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
