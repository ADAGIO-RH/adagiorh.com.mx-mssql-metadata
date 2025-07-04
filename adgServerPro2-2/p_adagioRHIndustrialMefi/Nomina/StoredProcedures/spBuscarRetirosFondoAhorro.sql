USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Nomina].[spBuscarRetirosFondoAhorro](
	 @IDRetiroFondoAhorro int=0			 
	,@IDFondoAhorro	int	--= 2
    ,@IDEmpleado int					
	,@IDUsuario int	
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Fecha'
    ,@orderDirection varchar(4) = 'desc'   
) as

DECLARE  
	    @TotalPaginas INT = 0
	   ,@TotalRegistros INT
	   ,@IDIdioma VARCHAR(20)
       ,@IDConcepto165 int ---Concepto Retiro Fondo Ahorro Empresa
       ,@IDConcepto166 int ---Concepto Retiro Fondo Ahorro Trabajador
       
	;

    

    SELECT @IDConcepto165=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='165'
    SELECT @IDConcepto166=IDConcepto FROM NOMINA.tblCatConceptos WHERE Codigo='166'
    

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

	IF OBJECT_ID('tempdb..#TempRetirosFondoAhorro') IS NOT NULL DROP TABLE #TempRetirosFondoAhorro;


	SELECT 
		 rfa.IDRetiroFondoAhorro
		,rfa.IDEmpleado	
        ,rfa.IDFondoAhorro			
		, p.IDPeriodo
		, p.ClavePeriodo as Periodo
        , UPPER(p.Descripcion) as DescripcionPeriodo
        , p.FechaFinPago as Fecha		
        ,isnull(rfa.MontoEmpresa,0) as MontoEmpresa
		,isnull(rfa.MontoTrabajador,0) as MontoTrabajador
		,isnull(rfa.MontoEmpresa,0)+isnull(rfa.MontoTrabajador,0) as Importe        
		,'' Descripcion		
        ,CASE WHEN ISNULL(P.Cerrado,0)=1 AND (DP165.IDDetallePeriodo IS NOT NULL AND DP166.IDDetallePeriodo IS NOT NULL) THEN 'APLICADO' ELSE 'PENDIENTE' END AS Estatus
		,CASE WHEN ISNULL(P.Cerrado,0)=1 AND (DP165.IDDetallePeriodo IS NOT NULL AND DP166.IDDetallePeriodo IS NOT NULL) THEN cast(1 as bit) ELSE cast(0 as bit) END AS Pagado
    INTO #TempRetirosFondoAhorro
	FROM Nomina.tblRetirosFondoAhorro rfa
		INNER JOIN Nomina.tblCatPeriodos P 
            on rfa.IDPeriodo = P.IDPeriodo
        LEFT JOIN Nomina.tblDetallePeriodo dp165
            on p.IDPeriodo=dp165.IDPeriodo 
            and dp165.IDConcepto=@IDConcepto165
        LEFT JOIN Nomina.tblDetallePeriodo dp166
            on p.IDPeriodo=dp166.IDPeriodo 
            and dp166.IDConcepto=@IDConcepto166
	WHERE rfa.IDEmpleado = @IDEmpleado 
        AND RFA.IDFondoAhorro=@IDFondoAhorro
        AND ((RFA.IDRetiroFondoAhorro = @IDRetiroFondoAhorro) or (@IDRetiroFondoAhorro = 0))
        AND ((@query = '""') OR CONTAINS(p.*, @query))

    
    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempRetirosFondoAhorro

	select @TotalRegistros = cast(COUNT(IDRetiroFondoAhorro) as decimal(18,2)) from #TempRetirosFondoAhorro
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempRetirosFondoAhorro
	order by 	
		case when @orderByColumn = 'Fecha' and @orderDirection = 'asc'	then Fecha end,			
		case when @orderByColumn = 'Fecha' and @orderDirection = 'desc'	then Fecha end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
