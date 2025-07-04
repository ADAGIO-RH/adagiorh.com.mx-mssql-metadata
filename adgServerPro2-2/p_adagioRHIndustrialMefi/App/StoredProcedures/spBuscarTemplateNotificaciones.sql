USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [App].[spBuscarTemplateNotificaciones](
	@IDTemplateNotificacion INT = NULL
	,@IDUsuario int = null
	,@PageNumber	int = 1
	,@PageSize		int = 10
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'IDTipoNotificacion'
	,@orderDirection varchar(4) = 'asc'
	)
AS
BEGIN
	SET FMTONLY OFF;  
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@IDIdioma varchar(20);

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'IDTipoNotificacion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse   
 
	SELECT 
		B.IDTemplateNotificacion
		,B.IDTipoNotificacion
		,A.Nombre as TipoNotificacion
		,B.IDMedioNotificacion
		,JSON_VALUE(C.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as MedioNotificacion
		,B.IDIdioma
		,E.Idioma as Idioma
		,Template
		--,B.IDTemplateNotificacion, A.Nombre, C.Traduccion AS MedioNotificacion, B.Template, E.Idioma
		into #TempResponse
		FROM App.tblTiposNotificaciones A 
		RIGHT JOIN App.tblTemplateNotificaciones B ON B.IDTipoNotificacion = A.IDTipoNotificacion
		RIGHT JOIN App.tblMediosNotificaciones C ON C.IDMedioNotificacion = B.IDMedioNotificacion
		RIGHT JOIN App.tblIdiomas E ON E.IDIdioma = B.IDIdioma
	WHERE (B.IDTemplateNotificacion = @IDTemplateNotificacion or isnull(@IDTemplateNotificacion,0) =0)   
        and (@query = '""' or contains(B.*, @query)) 
	ORDER BY B.IDTipoNotificacion ASC

		select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDTemplateNotificacion) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'IDTipoNotificacion'	and @orderDirection = 'asc'	then IDTipoNotificacion end,			
		case when @orderByColumn = 'IDTipoNotificacion'	and @orderDirection = 'desc'then IDTipoNotificacion end desc,
		case when @orderByColumn = 'IDMedioNotificacion'	and @orderDirection = 'asc'	then IDMedioNotificacion end,			
		case when @orderByColumn = 'IDMedioNotificacion'	and @orderDirection = 'desc'then IDMedioNotificacion end desc,
		case when @orderByColumn = 'IDIdioma'	and @orderDirection = 'asc'	then IDIdioma end,			
		case when @orderByColumn = 'IDIdioma'	and @orderDirection = 'desc'then IDIdioma end desc,
		IDTipoNotificacion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END


/*
exec [App].[spBuscarTemplateNotificaciones]
	@IDTemplateNotificacion = 0
	,@IDUsuario = 0
	,@PageNumber	 = 1
	,@PageSize		 = 10
	,@query			 = 'ActivarC'
	--,@orderByColumn	= 'IDTipoNotificacion'
	--,@orderDirection = 'asc'


*/
GO
