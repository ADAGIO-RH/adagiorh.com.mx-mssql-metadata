USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Nomina].[spBuscarAumentoMasivoEmpleado](
	 @IDAumentoMasivoEmpleado int = 0
    ,@IDEmpleado int = 0
    ,@IDAumentoMasivo int = 0 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'IDAumentoMasivoEmpleado'
	,@orderDirection varchar(4) = 'desc'
	,@IDUsuario int
) as

	SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int, 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'IDAumentoMasivoEmpleado' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"'+@query + '*"' end

	IF OBJECT_ID('tempdb..#TempAumentoMasivoEmpleado') IS NOT NULL DROP TABLE #TempAumentoMasivoEmpleado; 

	 SELECT 
         [AME].[IDAumentoMasivoEmpleado]
        ,[AME].[IDAumentoMasivo]
        ,[AME].[IDEmpleado]
        ,[AME].[SalarioDiario]
        ,[AME].[SalarioIntegrado]
        ,[AME].[SalarioVariable]
        ,[AME].[SalarioDiarioReal]
        ,[AME].[IDRegPatronal]
        ,[AME].[IDMovAfiliatorio]        
        ,[AM].[Descripcion]
        ,[AM].[Ejercicio]
        ,[AM].[FechaCreacion]
        ,[AM].[IDTipoAumentoMasivo]
        ,JSON_VALUE(CTAM.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoAumentoMasivo         
        ,[AM].[IDEstatusAumentoMasivo]
        ,JSON_VALUE(CEAM.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusAumentoMasivo 
        ,ISNULL([AM].[IDRazonMovimiento],0) AS IDRazonMovimiento
        ,ISNULL([CRM].[Descripcion],'SIN RAZÓN DE MOVIMIENTO ASIGNADA') AS RazonMovimiento        
        ,[AM].[FechaAplicacionMov]
        ,[AM].[RespetarSalarioVariable]
        ,[AM].[AfectaSalarioDiario]
        ,[AM].[AfectaSalarioDiarioReal]
        ,[AM].[ValorAumento]
        ,[AM].[IDUsuario]
        ,[E].[ClaveEmpleado]
        ,[E].[NOMBRECOMPLETO]
    INTO #TempAumentoMasivoEmpleado
    FROM NOMINA.tblAumentoMasivoEmpleado AME
        INNER JOIN NOMINA.tblAumentoMasivo AM with (nolock)
            ON AME.IDAumentoMasivo=AM.IDAumentoMasivo
        INNER JOIN NOMINA.tblCatTipoAumentoMasivo CTAM with (nolock)
            ON CTAM.IDTipoAumentoMasivo=AM.IDTipoAumentoMasivo
        INNER JOIN NOMINA.tblCatEstatusAumentoMasivo CEAM with (nolock)
            ON CEAM.IDEstatusAumentoMasivo=AM.IDEstatusAumentoMasivo
        LEFT JOIN IMSS.tblCatRazonesMovAfiliatorios CRM with (nolock)
            ON CRM.IDRazonMovimiento = AM.IDRazonMovimiento  
        INNER JOIN RH.tblEmpleadosMaster E with (nolock)
            ON E.IDEmpleado=AME.IDEmpleado  
    WHERE 
        (AME.IDAumentoMasivoEmpleado = @IDAumentoMasivoEmpleado or isnull(@IDAumentoMasivoEmpleado, 0) = 0)   
        AND (AME.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado, 0) = 0)   
        AND (AM.IDAumentoMasivo = @IDAumentoMasivo or isnull(@IDAumentoMasivo, 0) = 0)   
        AND ( (@query = '""' or contains(AM.*, @query)) OR
			(@query = '""' or contains(CTAM.*, @query)) OR
			(@query = '""' or contains(CEAM.*, @query)) OR
            (@query = '""' or contains(E.*, @query)) )

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempAumentoMasivoEmpleado

	select @TotalRegistros = cast(COUNT(IDAumentoMasivoEmpleado) as decimal(18,2)) from #TempAumentoMasivoEmpleado		
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempAumentoMasivoEmpleado
	order by 	
		case when @orderByColumn = 'IDAumentoMasivoEmpleado' and @orderDirection = 'asc'	then IDAumentoMasivoEmpleado end,			
		case when @orderByColumn = 'IDAumentoMasivoEmpleado' and @orderDirection = 'desc'	then IDAumentoMasivoEmpleado end desc,		
			IDAumentoMasivoEmpleado asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
