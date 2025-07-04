USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBuscarClienteBroker(
	@IDClienteBroker int = 0
	,@IDCliente int = 0
	,@IDCatBroker int = 0
	,@IDUsuario int = null  
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Broker'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Broker' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		 CB.IDClienteBroker
		,CB.IDCliente
		,C.NombreComercial as Cliente
		,CB.IDCatBroker
		,B.Codigo +' - '+ B.Nombre as [Broker]
	into #tempResponse
	FROM [Procom].[TblClienteBrokers] CB with(nolock)     
		inner join [RH].[tblCatClientes] C with(nolock)
			on CB.IDCliente = C.IDCliente
		Inner join [Procom].[TblCatBrokers] B with(nolock)
			on b.IDCatBroker = CB.IDCatBroker
 	WHERE
		((CB.IDClienteBroker = @IDClienteBroker) OR (ISNULL(@IDClienteBroker,0) = 0))
		AND ((B.IDCatBroker = @IDCatBroker) OR (ISNULL(@IDCatBroker,0) = 0))
		AND ((C.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		AND (@query = '""' or contains(C.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteBroker) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Broker'			and @orderDirection = 'asc'		then Broker end,			
		case when @orderByColumn = 'Broker'			and @orderDirection = 'desc'	then Broker end desc,		
		Broker desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
