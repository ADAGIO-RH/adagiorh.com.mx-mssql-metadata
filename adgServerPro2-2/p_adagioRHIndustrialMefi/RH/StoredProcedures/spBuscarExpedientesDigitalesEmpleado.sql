USE [p_adagioRHIndustrialMefi]
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
2023-11-15			Justin Dávila			Agregamos fecha de vencimiento del documento y periodicidad
2023-11-16			Justin Dávila			Ordenamiento por IDExpedienteDigitalEmpleado
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
	,@orderByColumn	varchar(50) = 'IDExpedienteDigitalEmpleado'
	,@orderDirection varchar(4) = 'asc'

)
AS
BEGIN

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@ID_PERIODICIDAD_SIN_DEFINIR INT = 1
	   ,@ID_PERIODICIDAD_DIARIA INT = 2
	   ,@ID_PERIODICIDAD_SEMANAL INT = 3
	   ,@ID_PERIODICIDAD_QUINCENAL INT = 4
	   ,@ID_PERIODICIDAD_MENSUAL INT = 5
	   ,@ID_PERIODICIDAD_BIMESTRAL INT = 6
	   ,@ID_PERIODICIDAD_TRIMESTRAL INT = 7
	   ,@ID_PERIODICIDAD_SEMESTRAL INT = 8
	   	,@IDIdioma varchar(20)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'IDExpedienteDigitalEmpleado' else @orderByColumn  end 
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
			,ISNULL([EDE].[IDExpedienteDigital],1) as IDExpedienteDigital
			,CED.Caduca
			,ISNULL(CED.IDPeriodicidad, 0) as IDPeriodicidad
			,(case 
				when CED.Caduca = 1 and EDE.FechaVencimiento is null THEN
					case
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_DIARIA THEN dateadd(day, 1*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_SEMANAL THEN dateadd(week, 1*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_QUINCENAL then dateadd(week, 2*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_MENSUAL then dateadd(MONTH, 1*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_BIMESTRAL then dateadd(MONTH, 2*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_TRIMESTRAL then dateadd(MONTH, 3*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						when CED.IDPeriodicidad = @ID_PERIODICIDAD_SEMESTRAL then dateadd(MONTH, 5*ISNULL(CED.PeriodoVigenciaDocumento,1), ISNULL(EDE.FechaCreacion, CED.FechaHoraActualizacion))
						else CAST('9999-01-01' as datetime)
					end
				WHEN CED.Caduca = 1 AND EDE.FechaVencimiento IS NOT NULL THEN EDE.FechaVencimiento
				else CAST('9999-01-01' as datetime)
				end) as FechaVencimiento
			,ISNULL(CED.PeriodoVigenciaDocumento,0) as PeriodoVigenciaDocumento
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
		case when @orderByColumn = 'IDExpedienteDigitalEmpleado'			and @orderDirection = 'asc'		then [IDExpedienteDigitalEmpleado] end,			
		case when @orderByColumn = 'IDExpedienteDigitalEmpleado'			and @orderDirection = 'desc'	then [IDExpedienteDigitalEmpleado] end desc,
		[IDExpedienteDigitalEmpleado] asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
