USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spBuscarClienteCuotaAfiliacion](
	 @IDClienteCuotaAfiliacion int = 0
	,@IDCliente int = 0
	,@IDUsuario int = null  
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Anio'
    ,@orderDirection varchar(4) = 'desc'
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

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Anio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		CR.IDClienteCuotaAfiliacion
		,CR.IDCliente
		,C.NombreComercial as Cliente
		,CR.Anio
		,isnull(CR.Cuota,0.00) as Cuota
		,CR.Descripcion
		,isnull(CR.FechaVigencia,'9999-12-31') as FechaVigencia
	    ,UECA.EstatusCuotaAfiliacion
		,UECA.LayoutDescargable
		,UECA.FechaHora
	into #tempResponse
	FROM [Procom].[tblClienteCuotaAfiliacion] CR with(nolock)     
		inner join [RH].[tblCatClientes] C with(nolock)
			on CR.IDCliente = C.IDCliente	
		CROSS APPLY Procom.fnBuscarUltimoEstatusCuotaAfiliacion(CR.IDClienteCuotaAfiliacion,@IDUsuario) as UECA
 	WHERE
		((CR.IDClienteCuotaAfiliacion = @IDClienteCuotaAfiliacion) OR (ISNULL(@IDClienteCuotaAfiliacion,0) = 0))
		AND ((CR.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		--AND (@query = '""' or contains(CR.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteCuotaAfiliacion) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Anio'			and @orderDirection = 'asc'		then Anio end,			
		case when @orderByColumn = 'Anio'			and @orderDirection = 'desc'	then Anio end desc,		
		Anio desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END;
GO
