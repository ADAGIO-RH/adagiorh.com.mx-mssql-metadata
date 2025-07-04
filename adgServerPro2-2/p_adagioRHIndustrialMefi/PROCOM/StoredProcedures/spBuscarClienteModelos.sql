USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBuscarClienteModelos(
	@IDClienteModelo int = null
	,@IDCliente int = null
	,@IDUsuario int = null  
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'FechaIni'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaIni' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		CM.IDClienteModelo
		,CM.IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))as Cliente 
		,isnull(E.IDEmpresa,0) as IDEmpresa
		,e.NombreComercial as RazonSocial
		,CM.FechaIni as FechaIni
		,CM.FechaFin as FechaFin
	into #tempResponse
	FROM [Procom].[tblClienteModelos] CM with(nolock)     
		inner join [RH].[tblCatClientes] C with(nolock)
			on CM.IDCliente = C.IDCliente
		inner join [RH].[tblEmpresa] E with(nolock)
			on E.IdEmpresa = CM.IDEmpresa
 	WHERE
		((CM.IDClienteModelo = @IDClienteModelo) OR (ISNULL(@IDClienteModelo,0) = 0))
		AND ((CM.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		AND (@query = '""' or contains(E.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteModelo) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'FechaIni'			and @orderDirection = 'asc'		then FechaIni end,			
		case when @orderByColumn = 'FechaIni'			and @orderDirection = 'desc'	then FechaIni end desc,		
		FechaIni desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
