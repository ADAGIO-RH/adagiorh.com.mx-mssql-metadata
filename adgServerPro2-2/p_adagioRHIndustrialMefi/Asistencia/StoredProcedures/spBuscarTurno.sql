USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBuscarTurno](
	 @IDTurno int = null 
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Descripcion'
	,@orderDirection varchar(4) = 'asc'
    ) as
    begin

		declare  
		   @TotalPaginas int = 0
		   ,@TotalRegistros int	
			,@IDIdioma varchar(max)
		;

		
		set @query = case 
			when @query is null then '""' 
			when @query = '' then '""'
			when @query = '""' then '""'
		else '"'+@query + '*"' end
  
		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
		if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
		if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

		select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

		IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	   select 
		  ct.IDTurno
		  ,ct.IDTipoJornadaSAT
		  ,UPPER(ctj.Descripcion) as TipoJornadaSAT
		  ,UPPER(ct.Descripcion	) AS Descripcion
		  ,ROW_NUMBER()over(ORDER BY IDTurno)as ROWNUMBER 
		  into #TempResponse
	   from [Asistencia].[tblCatTurnos] ct with (nolock)
		  left join  [Sat].[tblCatTiposJornada] ctj on ct.IDTipoJornadaSAT = ctj.IDTipoJornada
	   where (ct.IDTurno = @IDTurno or isnull(@IDTurno,0) = 0)
	   	and (@query = '""' or contains(ct.*, @query) OR
            @query = '""' or contains(ctj.*, @query)) 
	   

		select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDTurno) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,		
		Descripcion asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


end;
GO
