USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Norma35].[spBuscarPreguntasExtrasEncuestas](
	@IDPreguntaExtraEncuesta int = 0
	,@IDEncuesta int = 0
	,@IDUsuario int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Pregunta'
	,@orderDirection varchar(4) = 'asc'
) as
begin
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int	
		,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#tempResponse') IS NOT NULL DROP TABLE #tempResponse;

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	select 
		pee.IDPreguntaExtraEncuesta
		,pee.IDEncuesta
		,pee.IDTipoPreguntaExtra
		,ctpe.Nombre as TipoPreguntaExtra
		,pee.Pregunta
		,pee.Descripcion
		,pee.Placeholder
		,pee.RespuestaLarga
		,pee.Requerida
		,pee.FechaHoraRegistro
		,pee.IDUsuarioCrea
	INTO #tempResponse
	from [Norma35].[tblPreguntasExtrasEncuestas] pee
		join [Norma35].[tblCatTiposPreguntasExtras] ctpe on ctpe.IDTipoPreguntaExtra = pee.IDtipoPreguntaExtra
	where (pee.IDPreguntaExtraEncuesta = @IDPreguntaExtraEncuesta or isnull(@IDPreguntaExtraEncuesta, 0) = 0)
		and (pee.IDEncuesta = @IDEncuesta or isnull(@IDEncuesta, 0) = 0)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDPreguntaExtraEncuesta) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Pregunta'	and @orderDirection = 'asc'		then Pregunta end,			
		case when @orderByColumn = 'Pregunta'	and @orderDirection = 'desc'	then Pregunta end desc,		
		Pregunta asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
