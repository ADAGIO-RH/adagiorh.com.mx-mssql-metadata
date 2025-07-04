USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca Tipos de Preguntas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-25
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
04-08-2022		Alejandro Paredes	Se agrego la columna ConfPregunta	
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarTiposPreguntas](
	@IDTipoPregunta int  = 0
    ,@IDUsuario int =0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'TipoPregunta'
	,@orderDirection varchar(4) = 'asc'
) as
DECLARE 
   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDIdioma varchar(max)
	;
   select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'TipoPregunta' else @orderByColumn  end 
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

	select tp.IDTipoPregunta
		, ISNULL(UPPER (JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoPregunta'))),tp.TipoPregunta) as TipoPregunta
		, ISNULL(UPPER (JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))),tp.Descripcion) as Descripcion
		,isnull(tp.TiempoEstimadoRespuesta,0) as TiempoEstimadoRespuesta
		,isnull(tp.IDUnidadDeTiempo,0) as IDUnidadDeTiempo
		,u.Nombre as UnidadTiempo
		,tp.IDTemplate
		,tp.IDTemplateEdicion
		,tp.CssClass
		,tp.ConfPregunta
		,tp.Component
		,tp.ComponentEvaluacion
		,tp.InputType
        ,tp.Traduccion
		,ROWNUMBER = ROW_NUMBER()OVER(ORDER BY tp.TipoPregunta ASC) 
		into #TempResponse
	from [Evaluacion360].[tblCatTiposDePreguntas] tp
		left join App.[tblCatUnidadesDeTiempo] u on tp.IDUnidadDeTiempo = u.IDUnidadDeTiempo
	where tp.IDTipoPregunta = @IDTipoPregunta or (@IDTipoPregunta=0)
	order by tp.TipoPregunta asc

		select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempResponse

	select @TotalRegistros = cast(COUNT([IDTipoPregunta]) as decimal(18,2)) from #TempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,@TotalRegistros as TotalRegistros
	from #TempResponse
	order by 
		case when @orderByColumn = 'TipoPregunta'			and @orderDirection = 'asc'		then TipoPregunta end,			
		case when @orderByColumn = 'TipoPregunta'			and @orderDirection = 'desc'	then TipoPregunta end desc,		
		TipoPregunta asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
