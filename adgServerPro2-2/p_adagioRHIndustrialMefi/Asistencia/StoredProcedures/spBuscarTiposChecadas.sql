USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS TIPOS DE CHECADAS
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spBuscarTiposChecadas]
(
	@IDTipoChecada Varchar(10) = NULL
    ,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'TipoChecada'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
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


	SELECT 
		IDTipoChecada
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoChecada')) as TipoChecada 
		,isnull(Activo,0) as Activo 
		,ROW_NUMBER()OVER(ORDER BY IDTipoChecada ASC) as ROWNUMBER
		into #TempResponse
	from Asistencia.tblCatTiposChecadas tc
	WHERE ((IDTipoChecada = @IDTipoChecada) OR (ISNULL(@IDTipoChecada,'') = ''))
	 	and (@query = '""' or contains(tc.*, @query)) 

		select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDTipoChecada) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'TipoChecada'			and @orderDirection = 'asc'		then TipoChecada end,			
		case when @orderByColumn = 'TipoChecada'			and @orderDirection = 'desc'	then TipoChecada end desc,		
		TipoChecada asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
