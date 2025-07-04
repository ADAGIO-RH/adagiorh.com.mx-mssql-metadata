USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Evaluacion360].[spBuscarCiclosMedicionObjetivos](
	@IDCicloMedicionObjetivo int = 0
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Fecha'
	,@orderDirection varchar(4) = 'desc'
	,@IDUsuario int
) aS

    DECLARE  
	   @TotalPaginas INT = 0
	   ,@TotalRegistros INT, 
		@IDIdioma VARCHAR(20)
	;

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	IF (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	SELECT
		 @orderByColumn	 = CASE WHEN @orderByColumn	 IS NULL THEN 'Fecha' ELSE @orderByColumn  END
		,@orderDirection = CASE WHEN @orderDirection IS NULL THEN  'desc' ELSE @orderDirection END

	SET @query = CASE
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				    ELSE '"'+@query + '*"' END

	IF OBJECT_ID('tempdb..#TempCicloMedicionObjetivo') IS NOT NULL DROP TABLE #TempCicloMedicionObjetivo; 

	select 
		ccmo.IDCicloMedicionObjetivo
		,UPPER(ccmo.Nombre) as Nombre
		,ccmo.FechaInicio
		,ccmo.FechaFin
		,ccmo.IDEstatusCicloMedicion
		,JSON_VALUE(ecm.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as EstatusCicloMedicion
		,ccmo.FechaParaActualizacionEstatusObjetivos
        ,ccmo.PermitirIngresoObjetivosEmpleados
        ,ccmo.EmpleadoApruebaObjetivos
        ,ccmo.IDUsuario
		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario        
	INTO #TempCicloMedicionObjetivo
    from Evaluacion360.tblCatCiclosMedicionObjetivos ccmo
		join Evaluacion360.tblCatEstatusCiclosMedicion ecm on ecm.IDEstatusCicloMedicion = ccmo.IDEstatusCicloMedicion
		join Seguridad.tblUsuarios u on u.IDUsuario = ccmo.IDUsuario
	WHERE (ccmo.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0)    	
        and (@query = '""' or contains(ccmo.*, @query)) 

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempCicloMedicionObjetivo

	select @TotalRegistros = cast(COUNT(IDCicloMedicionObjetivo) as decimal(18,2)) from #TempCicloMedicionObjetivo
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempCicloMedicionObjetivo
	order by 	
		case when @orderByColumn = 'FechaInicio' and @orderDirection = 'asc'	then FechaInicio end,			
		case when @orderByColumn = 'FechaInicio' and @orderDirection = 'desc'	then FechaInicio end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
