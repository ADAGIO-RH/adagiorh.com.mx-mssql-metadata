USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarEstados_VUE] -- null, 188
(
	@IDEstado int=0
	,@IDPais int = 0
    ,@IDUsuario int =0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
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
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'Estados'  

	select 
		IDEstado
		,UPPER(CE.Codigo) AS Codigo
		,UPPER(CE.NombreEstado) AS NombreEstado
		,CP.IDPais as IDPais 
		,UPPER(CP.Descripcion) AS Pais        
          into #TempResponse
	From [Sat].[tblCatEstados] CE
    left join sat.tblCatPaises CP on CE.IDPais = CP.IDPais
	where (CE.IDPais = @IDPais or  isnull(@IDPais,0) = 0 OR IDEstado = 96) 	
	  and (@query = '""' or contains(CE.*, @query)) 
	    ORDER BY CP.IDPais ASC


        select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDEstado) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		
		case when @orderByColumn = 'Pais'			and @orderDirection = 'desc'	then Pais end desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
