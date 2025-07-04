USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spBuscarPreguntasFiltro](
	 @IDPreguntaFiltro [int] = null,
	 @TipoReferencia int,
	 @IDReferencia int null,
	 @IDUsuario int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'IDPreguntaFiltro'
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

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  


	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'IDPreguntaFiltro' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	SELECT     
		 p.IDPreguntaFiltro
		,p.IDTipoPreguntaFiltro
		,tp.Descripcion as TipoPreguntaFiltro
		,tp.Component as Component
		,tp.InputType as InputType
		,p.Pregunta
		,p.Respuestas
		,isnull(p.TipoReferencia,0) as TipoReferencia
		,isnull(p.IDReferencia,0) as IDReferencia
	into #tempResponse
	FROM [Reclutamiento].[tblPreguntasFiltro] p with(nolock)     
		inner join [Reclutamiento].tblCatTipoPreguntaFiltro tp with(nolock)
			on p.IDTipoPreguntaFiltro = tp.IDTipoPreguntaFiltro
	WHERE
		( 
            (p.IDPreguntaFiltro = @IDPreguntaFiltro or isnull(@IDPreguntaFiltro,0) =0)
			and (p.TipoReferencia = @TipoReferencia or isnull(@TipoReferencia,0) = 0)
			and (p.IDReferencia = @IDReferencia or isnull(@IDReferencia,0) = 0) 
        )  
		and (@query = '""' or contains(p.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDPreguntaFiltro) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'IDPreguntaFiltro'			and @orderDirection = 'asc'		then IDPreguntaFiltro end,			
		case when @orderByColumn = 'IDPreguntaFiltro'			and @orderDirection = 'desc'	then IDPreguntaFiltro end desc,		
		IDPreguntaFiltro asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
