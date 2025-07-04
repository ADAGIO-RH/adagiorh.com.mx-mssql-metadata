USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Nomina].[spBuscarAumentoMasivo](
	@IDAumentoMasivo int = 0		
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Ejercicio'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Ejercicio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 
    
    set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"'+@query + '*"' end

	IF OBJECT_ID('tempdb..#TempAumentoMasivo') IS NOT NULL DROP TABLE #TempAumentoMasivo; 

	
    SELECT 
         [AM].[IDAumentoMasivo]
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
        ,[U].[IDUsuario]
        ,coalesce(U.Nombre, '')+' '+coalesce(U.Apellido, '') as Usuario
    INTO #TempAumentoMasivo
    FROM NOMINA.tblAumentoMasivo AM
        INNER JOIN NOMINA.tblCatTipoAumentoMasivo CTAM
            ON CTAM.IDTipoAumentoMasivo=AM.IDTipoAumentoMasivo
        INNER JOIN NOMINA.tblCatEstatusAumentoMasivo CEAM
            ON CEAM.IDEstatusAumentoMasivo=AM.IDEstatusAumentoMasivo
        INNER JOIN Seguridad.tblUsuarios u
            ON U.IDUsuario = AM.IDUsuario 
        LEFT JOIN IMSS.tblCatRazonesMovAfiliatorios CRM
            ON CRM.IDRazonMovimiento = AM.IDRazonMovimiento    
                   
        
    WHERE 
        (AM.IDAumentoMasivo = @IDAumentoMasivo or isnull(@IDAumentoMasivo, 0) = 0)           
        and ( (@query = '""' or contains(AM.*, @query)) OR
			(@query = '""' or contains(CTAM.*, @query)) OR
			(@query = '""' or contains(CEAM.*, @query)) )
			

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from  #TempAumentoMasivo

	select @TotalRegistros = cast(COUNT(IDAumentoMasivo) as decimal(18,2)) from #TempAumentoMasivo		
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempAumentoMasivo
	order by 	
		case when @orderByColumn = 'Ejercicio' and @orderDirection = 'asc'	then Ejercicio end,			
		case when @orderByColumn = 'Ejercicio' and @orderDirection = 'desc'	then Ejercicio end desc,		
			Ejercicio asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
