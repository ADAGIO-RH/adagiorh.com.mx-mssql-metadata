USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarCatWidgets](
    @IDAplicacion Varchar(50) =null
	,@Component Varchar(50) = null   
	,@Activo bit
	,@IDUsuario int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Orden'
	,@orderDirection varchar(4) = 'asc'
)
AS BEGIN
    	SET FMTONLY OFF;  
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end
    	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Orden' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

    SELECT 
    [IDWidget],
    [IDAplicacion],
    [Component],
    [Nombre],
    [Activo],
    [Orden],
	ROWNUMBER = ROW_NUMBER()OVER(ORDER BY Orden ASC) 
	into #TempResponse
	FROM [App].[tblCatWidgets]
	WHERE IDAplicacion = @IDAplicacion OR isnull(@IDAplicacion,'') = ''

        --and (@query = '""' or contains(RH.tblCatWidgets.*, @query)) 
	ORDER BY Orden ASC

		select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDWidget) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Orden'			and @orderDirection = 'asc'		then Orden end,			
		case when @orderByColumn = 'Orden'			and @orderDirection = 'desc'	then Orden end desc,
		Orden asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END;
GO
