USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Estatus
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-25
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarCatEstatus](
	@IDEstatus int = 0
	,@IDTipoEstatus int = 0
	,@IDUsuario int
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'TipoEstatus'
	,@orderDirection varchar(4) = 'asc'
) as
Declare 
     @TotalPaginas int = 0
	,@TotalRegistros int = 0
    ,@IDIdioma VARCHAR(max)

select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'TipoEstatus' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

		IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'TipoPregunta' 
  
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	select 
		 e.IDEstatus
		,e.IDTipoEstatus
		,JSON_VALUE(te.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoEstatus')) as TipoEstatus
		,JSON_VALUE(e.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) as Estatus
		,e.Color
		,e.Icono
		,isnull(e.TotalEvaluaciones, 0) as TotalEvaluaciones
        	,ROWNUMBER = ROW_NUMBER()OVER(ORDER BY e.IDTipoEstatus ASC) 
		into #TempResponse
	from [Evaluacion360].[tblCatEstatus] e
		join [Evaluacion360].[tblCatTiposEstatus] te on e.IDTipoEstatus = te.IDTipoEstatus
	where (IDEstatus = @IDEstatus or isnull(@IDEstatus, 0) = 0)
		and (te.IDTipoEstatus = @IDTipoEstatus or isnull(@IDTipoEstatus, 0) = 0)
        	order by e.IDTipoEstatus asc

            select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempResponse

	select @TotalRegistros = cast(COUNT([IDEstatus]) as decimal(18,2)) from #TempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,@TotalRegistros as TotalRegistros
	from #TempResponse
	order by 
		case when @orderByColumn = 'TipoEstatus'			and @orderDirection = 'asc'		then TipoEstatus end,			
		case when @orderByColumn = 'TipoEstatus'			and @orderDirection = 'desc'	then TipoEstatus end desc,		
		TipoEstatus asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
