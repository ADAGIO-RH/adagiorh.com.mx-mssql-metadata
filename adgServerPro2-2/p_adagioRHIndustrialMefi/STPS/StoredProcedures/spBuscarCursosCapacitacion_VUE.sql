USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [STPS].[spBuscarCursosCapacitacion_VUE]
(
	@IDCursoCapacitacion int = 0
    ,@Area Varchar(50) = null
	,@IDUsuario int =null
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

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse ;
	
	
	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'CursoCapacitacion'  

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end
	
	SELECT CC.IDCursoCapacitacion,
		   UPPER(CC.Codigo) as Codigo,
		   UPPER(CC.Nombre) as Nombre,
		   ISNULL(CC.IDAreaTematica, 0) as IDAreaTematica,
		   UPPER(T.Codigo) as CodigoAreaTematica,
		   UPPER(T.Descripcion) as AreaTematica,
		   ISNULL(CC.IDCapacitaciones,0) as IDCapacitaciones,
		   UPPER(CP.Codigo) as CodigoCapacitaciones,
		   UPPER(CP.Descripcion) as Capacitaciones,
		   CC.Color,
		   isnull(CC.IDCurso,0) as IDCurso,
		   UPPER(C.Descripcion) as Curso,
		   ROW_NUMBER()OVER(ORDER BY CC.IDCursoCapacitacion ASC) as ROWNUMBER
           	Into #TempResponse
	FROM STPS.tblCursosCapacitacion CC
		left join STPS.tblCatTematicas T
			on CC.IDAreaTematica = T.IDTematica
		Left join STPS.tblCatCapacitaciones CP
			on CP.IDCapacitaciones = CC.IDCapacitaciones
		Left Join STPS.tblCatCursos C
			on CC.IDCurso = C.IDCursos
	WHERE ((CC.IDCursoCapacitacion = @IDCursoCapacitacion) OR (@IDCursoCapacitacion = 0))
		and (@query = '""' or contains(CC.*, @query)) 
    	order by CC.Nombre desc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(@IDCursoCapacitacion) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end			
		--case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,
		--Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);



END;
GO
