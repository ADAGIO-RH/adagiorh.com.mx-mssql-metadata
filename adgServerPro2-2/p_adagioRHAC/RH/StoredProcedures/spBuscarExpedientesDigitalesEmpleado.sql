USE [p_adagioRHAC]
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
0000-00-00		    NombreCompleto		    ¿Qué cambió?
2023-03-23			JOSÉ ROMÁN				REFACTORIZACIÓN CON PAGINACIÓN
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarExpedientesDigitalesEmpleado]-- @IDUsuario = 1
(
	@IDExpedienteDigitalEmpleado int = 0
	,@IDCarpetaExpedienteDigital int = 0
	,@IDEmpleado int = 0
	,@IDUsuario int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Name'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Name' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  
  		set @query = case 
			when @query is null then '""' 
			when @query = '' then '""'
			when @query = '""' then '""'
		else '"'+@query + '*"' end


		SELECT
	         [EDE].[IDExpedienteDigitalEmpleado]
			,[EDE].[IDEmpleado]
			,[EDE].[Name]
			,[EDE].[ContentType]
			,[EDE].[PathFile]
			,[EDE].[Size]
			,ISNULL([EDE].[IDExpedienteDigital],0) as IDExpedienteDigital
			,[CED].[Codigo] as CodigoExpedientDigital
			,[CED].[Descripcion] as DescripcionExpedientDigital
			,isnull([CED].[Requerido],0) as Requerido
			,ISNULL([CCED].[IDCarpetaExpedienteDigital],0) as IDCarpetaExpedienteDigital
			,[CCED].Descripcion as CarpetaExpedienteDigital
			,ROW_NUMBER()over(ORDER BY [IDExpedienteDigitalEmpleado])as ROWNUMBER
		  into #tempResponse
		FROM [RH].[TblExpedienteDigitalEmpleado] EDE with(nolock)
		INNER JOIN [RH].[tblCatExpedientesDigitales] CED with(nolock) ON EDE.IDExpedienteDigital = CED.IDExpedienteDigital
		INNER JOIN [RH].[tblCatCarpetasExpedienteDigital] CCED with(nolock) on CCED.IDCarpetaExpedienteDigital = CED.IDCarpetaExpedienteDigital
		WHERE (EDE.[IDExpedienteDigitalEmpleado] = @IDExpedienteDigitalEmpleado OR isnull(@IDExpedienteDigitalEmpleado,0) = 0)
		AND (EDE.[IDEmpleado] = @IDEmpleado OR isnull(@IDEmpleado,0) = 0)
		and (@query = '""' or contains(CED.*, @query) or contains(CCED.*, @query)) 
		and (CED.IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital OR isnull(@IDCarpetaExpedienteDigital,0) = 0)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT([IDExpedienteDigitalEmpleado]) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Name'			and @orderDirection = 'asc'		then [Name] end,			
		case when @orderByColumn = 'Name'			and @orderDirection = 'desc'	then [Name] end desc,		
		[Name] asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
