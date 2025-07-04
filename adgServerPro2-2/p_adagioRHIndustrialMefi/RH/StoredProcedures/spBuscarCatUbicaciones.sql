USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatUbicaciones]
(
    @IDUbicacion int = NULL
    ,@IDUsuario int = NULL
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
	,@orderDirection varchar(4) = 'asc'
    ,@dtFiltros [Nomina].[dtFiltrosRH]  READONLY             
)
as BEGIN
SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	declare @tempResponse as table (
		     IDUbicacion  int   
                ,Nombre  varchar(20)
                ,Latitud  varchar(50)
                ,Longitud  varchar(25)
                ,Activo  bit     
                ,ROWNUMBER  int
	)
  
  IF OBJECT_ID('tempdb..#TempUbicaciones') IS NOT NULL DROP TABLE #TempUbicaciones 

	select ID   
		Into #TempUbicaciones  
	from Seguridad.tblFiltrosUsuarios with(nolock)  
	where IDUsuario = @IDUsuario and Filtro = 'Ubicaciones'  
   

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

    insert into @tempResponse(
				IDUbicacion     
                ,Nombre  
                ,Latitud 
                ,Longitud 
                ,Activo 
                ,ROWNUMBER )
    Select 
		IDUbicacion
		,UPPER(Nombre) as Nombre
   		,isnull(Latitud, 19.435717) as Latitud
		,isnull(Longitud, -99.073410) as Longitud
		,Cast(isnull(Activo,0) as bit) as Activo
		,ROW_NUMBER()over(ORDER BY IDUbicacion)as ROWNUMBER    
    from [RH].[tblCatUbicaciones] U With(Nolock)
	where ((IDUbicacion = @IDUbicacion or isnull(@IDUbicacion,0) = 0))    
		and (u.IDUbicacion in (select ID from #TempUbicaciones)   OR Not Exists(select ID from #TempUbicaciones))
		and  (@query = '""' or contains(u.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDUbicacion]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,			
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
