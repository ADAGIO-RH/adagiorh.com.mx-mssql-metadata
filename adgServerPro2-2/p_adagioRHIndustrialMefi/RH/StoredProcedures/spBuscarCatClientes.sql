USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spBuscarCatClientes](    
	@IDCliente int = null   
	,@IDUsuario int = null  
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
    ,@ValidarFiltros bit =1
)    
AS    
BEGIN    
	SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


	IF OBJECT_ID('tempdb..#TempClientesFiltros') IS NOT NULL DROP TABLE #TempClientesFiltros  
	IF OBJECT_ID('tempdb..#TempClientes') IS NOT NULL DROP TABLE #TempClientes
    
	select ID   
	Into #TempClientesFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'Clientes'  
  
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	SELECT     
		C.IDCliente    
		,cast(isnull(C.GenerarNoNomina,0) as bit) as GenerarNoNomina    
		,isnull(C.LongitudNoNomina,0) as LongitudNoNomina    
		,isnull(C.Prefijo,'') as Prefijo    
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))as NombreComercial    
		,ISNULL(C.Codigo,'') as Codigo    
		,isnull(RBTimbrado.NombreReporte,'')  as PathReciboNomina
		,isnull(RBNoTimbrado.NombreReporte,'')  as PathReciboNominaNoTimbrado
		,Traduccion
	into #TempClientes
	FROM RH.[tblCatClientes] C  with(nolock)   
		 left join Reportes.tblCatReportesBasicos RBTimbrado 
			on RBTimbrado.IDReporteBasico = COALESCE(JSON_VALUE(C.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'IDReporteNominaTimbrado')),'') 
		 left join Reportes.tblCatReportesBasicos RBNoTimbrado 
			on RBNoTimbrado.IDReporteBasico = COALESCE(JSON_VALUE(C.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'IDReporteNominaNoTimbrado')),'')
	WHERE (c.IDCliente = @IDCliente ) OR (isnull(@IDCliente,0) = 0)    
		and( (c.IDCliente in  ( select ID from #TempClientesFiltros)) OR NOT EXISTS (SELECT TOP 1 1 FROM #TempClientesFiltros  ) OR @ValidarFiltros=0)
		and (@query = '""' or contains(c.*, @query)) 
	
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempClientes

	select @TotalRegistros = cast(COUNT([IDCliente]) as decimal(18,2)) from #TempClientes		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,@TotalRegistros as TotalRegistros
	from #TempClientes
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,			
		case when @orderByColumn = 'NombreComercial'and @orderDirection = 'asc'		then NombreComercial end,			
		case when @orderByColumn = 'NombreComercial'and @orderDirection = 'desc'	then NombreComercial end desc,			
		case when @orderByColumn = 'Prefijo'	and @orderDirection = 'asc'		then Prefijo end,		
		case when @orderByColumn = 'Prefijo'	and @orderDirection = 'desc'	then Prefijo end desc,		
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
