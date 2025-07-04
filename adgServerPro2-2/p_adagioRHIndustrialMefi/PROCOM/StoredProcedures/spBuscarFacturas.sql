USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spBuscarFacturas](
	@IDFactura int = 0
	,@FechaIni date = '1900-01-01'
	,@Fechafin date = '9999-12-31'
	,@IDUsuario		int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Fecha'
	,@orderDirection varchar(4) = 'desc'
	,@TipoBusqueda int = 0
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;


	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Fecha' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
	--select @query

	SELECT     
		 F.IDFactura    
		,F.Fecha 
		,F.Folio
		,F.RFC
		,F.RazonSocial
		,F.Total
		,[Procom].[fnTotalFacturaPeriodo](F.IDFactura) as TotalConciliado
		,TotalPendiente = isnull(F.Total,0) - isnull([Procom].[fnTotalFacturaPeriodo](F.IDFactura),0)
		,CAST(isnull(F.Consolidado,0)as bit) as Consolidado
	into #tempResponse
	FROM [Procom].[TblFacturas] F with(nolock)     
	WHERE
       (f.IDFactura = @IDFactura or isnull(@IDFactura,0) =0)
        AND f.Fecha Between @FechaIni and @FechaFin
		and (@query = '""' or contains(F.*, @query)) 
		and ((isnull(@TipoBusqueda,0) = 0 and CAST(isnull(F.Consolidado,0)as bit) in (0,1)      
	   OR   (isnull(@TipoBusqueda,0) = 1 and CAST(isnull(F.Consolidado,0)as bit) in (1))
	   OR   (isnull(@TipoBusqueda,0) = 2 and CAST(isnull(F.Consolidado,0)as bit) in (0))
	   ))    
	   


	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDFactura) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'asc'		then Fecha end,			
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'desc'	then Fecha end desc,		
		Fecha asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
