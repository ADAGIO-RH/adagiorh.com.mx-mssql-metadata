USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarPorcentajesPago]
(    
    @IDPorcentajesPago int = null    
    ,@IDUsuario int
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Fecha'
    ,@orderDirection varchar(4) = 'asc'
)    
AS    
BEGIN  
    SET FMTONLY OFF;  
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
        ,@IDIdioma varchar(max)
	;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
                    when @query = '""' then '""'
				else '"'+@query + '*"' end

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Fecha' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

 Select     
  IDPorcentajesPago    
  ,Fecha    
  ,CuotaFija							= case when CuotaFija <> 0 THEN CuotaFija * 100 else 0 END    
  ,ExcedentePatronal					= case when ExcedentePatronal <> 0 THEN ExcedentePatronal * 100 else 0 END 
  ,ExcedenteObrera      				= case when ExcedenteObrera <> 0 THEN ExcedenteObrera * 100 else 0 END 
  ,PrestacionesDineroPatronal      		= case when PrestacionesDineroPatronal <> 0 THEN PrestacionesDineroPatronal * 100 else 0 END 
  ,PrestacionesDineroObrera      		= case when PrestacionesDineroObrera <> 0 THEN PrestacionesDineroObrera * 100 else 0 END 
  ,GMPensionadosPatronal      			= case when GMPensionadosPatronal <> 0 THEN GMPensionadosPatronal * 100 else 0 END 
  ,GMPensionadosObrera      			= case when GMPensionadosObrera <> 0 THEN GMPensionadosObrera * 100 else 0 END 
  ,RiesgosTrabajo      					= case when RiesgosTrabajo <> 0 THEN RiesgosTrabajo * 100 else 0 END 
  ,InvalidezVidaPatronal      			= case when InvalidezVidaPatronal <> 0 THEN InvalidezVidaPatronal * 100 else 0 END 
  ,InvalidezVidaObrera      			= case when InvalidezVidaObrera <> 0 THEN InvalidezVidaObrera * 100 else 0 END 
  ,GuarderiasPrestacionesSociales      	= case when GuarderiasPrestacionesSociales <> 0 THEN GuarderiasPrestacionesSociales * 100 else 0 END 
  ,CesantiaVejezPatron      			= case when CesantiaVejezPatron <> 0 THEN CesantiaVejezPatron * 100 else 0 END 
  ,SeguroRetiro      					= case when SeguroRetiro <> 0 THEN SeguroRetiro * 100 else 0 END 
  ,Infonavit      						= case when Infonavit <> 0 THEN Infonavit * 100 else 0 END 
  ,CesantiaVejezObrera      			= case when CesantiaVejezObrera <> 0 THEN CesantiaVejezObrera * 100 else 0 END 
  ,ReservaPensionado      				= case when ReservaPensionado <> 0 THEN ReservaPensionado * 100 else 0 END 
  ,CuotaProporcionalObrera      		= case when CuotaProporcionalObrera <> 0 THEN CuotaProporcionalObrera * 100 else 0 END  
  ,ROWNUMBER = ROW_NUMBER()OVER(ORDER BY Fecha ASC) 
  into #TempResponse  
 From [IMSS].[tblCatPorcentajesPago]  
 WHERE (IDPorcentajesPago = @IDPorcentajesPago or isnull(@IDPorcentajesPago,0) =0)
  
    --IDPorcentajesPago = @IDPorcentajesPago OR @IDPorcentajesPago is null    
  --ORDER BY Fecha DESC  
  
  select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(*) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'desc'		then Fecha end,			
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'asc'	then Fecha end desc,
		Fecha desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
