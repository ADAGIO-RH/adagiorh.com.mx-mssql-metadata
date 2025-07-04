USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Evaluacion360].[spBuscarCatEscalaValoracion](
	@IDEscalaValoracion int = 0
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
	,@orderDirection varchar(4) = 'asc'
    ,@IDUsuario int =0
) as
DECLARE 
   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0	   
	;


	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

		IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'Nombre' 
  
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	select e.IDEscalaValoracion
			,e.Nombre
			,Escala = ISNULL( STUFF(
							(   SELECT ', ('+ cast(Valor as varchar(10))+') '+ CONVERT(NVARCHAR(100), Nombre) 
								FROM [Evaluacion360].[tblDetalleEscalaValoracion] 
								WHERE IDEscalaValoracion = e.IDEscalaValoracion 
								ORDER BY isnull(valor,0) desc
								FOR xml path('')
							)
							, 1
							, 1
							, ''), 'Valores de la escala no definidos')
            ,ROWNUMBER = ROW_NUMBER()OVER(ORDER BY e.Nombre ASC) 
		into #TempResponse
	from [Evaluacion360].[tblCatEscalaValoracion] e
	where e.IDEscalaValoracion = @IDEscalaValoracion or @IDEscalaValoracion = 0
	ORDER BY e.Nombre desc

    	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempResponse

	select @TotalRegistros = cast(COUNT([IDEscalaValoracion]) as decimal(18,2)) from #TempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,@TotalRegistros as TotalRegistros
	from #TempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,		
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
