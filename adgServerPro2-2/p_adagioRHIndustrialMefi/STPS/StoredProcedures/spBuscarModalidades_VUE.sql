USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarModalidades_VUE]
(
	@IDModalidad int = null
       ,@IDUsuario		int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Descripcion'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
SET FMTONLY OFF;  
    DECLARE
  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
       
	;


	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
	
	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+ @query + '*"' end
	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'Modalidades'  

		select 
		IDModalidad
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
         INTO #TempResponse
		From [STPS].[tblCatModalidades]
		where (IDModalidad = @IDModalidad or isnull(@IDModalidad, 0) = 0)
        and (@query = '""' OR CONTAINS((Codigo, Descripcion), @query))             
	
    ORDER BY Codigo ASC

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempResponse

	select @TotalRegistros = cast(COUNT(IDModalidad) as decimal(18,2)) from #TempResponse		

	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempResponse
	order by 	
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end asc			
		-- case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc		
		-- Codigo

	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
