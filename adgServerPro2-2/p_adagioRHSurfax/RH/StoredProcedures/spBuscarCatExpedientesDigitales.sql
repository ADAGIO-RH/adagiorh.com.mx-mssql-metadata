USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Buscar el Catálogo de ExpedientesDigitales>
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
2024-05-29		    Justin Davila		    Valor por defecto de IDPeriodicidad = 2 para mejorar experiencia de usuario
2024-05-30		    Justin Davila		    Valor por defecto de IDPeriodicidad = 0 para mejorar experiencia de usuario
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarCatExpedientesDigitales](
	@IDExpedienteDigital int = 0
	,@IDCarpetaExpedienteDigital int = 0
	,@IDUsuario int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Descripcion'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	declare  
		 @TotalPaginas int = 0
		,@TotalRegistros int
		,@IDIdioma varchar(20)
	;
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  
  	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

    SELECT
		CED.[IDExpedienteDigital]
		,CED.[Codigo]
		,CED.[Descripcion]
		,CED.[Requerido]
		,ISNULL(CED.[IDCarpetaExpedienteDigital],0) as IDCarpetaExpedienteDigital
		,ISNULL(CED.IDPeriodicidad, 0) as IDPeriodicidad
		,CED.Caduca
		,CCED.Descripcion as CarpetaExpedienteDigital
		,case when lower(replace(@IDIdioma, '-','')) ='esmx' then iif([Requerido] = 1,'Si','No') else iif([Requerido] = 1,'Yes','No') end as [RequeridoTexto]
		,isnull(CED.FechaHoraActualizacion, getdate()) as FechaHoraActualizacion
		,ISNULL(CED.PeriodoVigenciaDocumento, 0) as PeriodoVigenciaDocumento
        ,isnull(ced.Intranet,0) as Intranet
		,isnull(ced.IntranetConfig, '{ Editable: false }') as IntranetConfig
        ,isnull(ced.Reclutamiento,0) as Reclutamiento
		,ROW_NUMBER()over(ORDER BY [IDExpedienteDigital])as ROWNUMBER
	into #tempResponse
	FROM [RH].[tblCatExpedientesDigitales] CED with(nolock)
		inner join RH.tblCatCarpetasExpedienteDigital CCED with(nolock)
			on CED.IDCarpetaExpedienteDigital = CCED.IDCarpetaExpedienteDigital
	WHERE (CED.IDExpedienteDigital = @IDExpedienteDigital OR isnull(@IDExpedienteDigital,0) = 0)
		and (@query = '""' or contains(CED.*, @query) or contains(CCED.*, @query)) 
		and (CED.IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital OR isnull(@IDCarpetaExpedienteDigital,0) = 0)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDExpedienteDigital) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,		
		Descripcion asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
