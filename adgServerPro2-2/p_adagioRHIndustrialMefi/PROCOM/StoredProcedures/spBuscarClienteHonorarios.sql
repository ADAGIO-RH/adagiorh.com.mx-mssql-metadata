USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spBuscarClienteHonorarios](
	@IDClienteHonorario int = 0
	,@IDCliente int = 0
	,@IDUsuario int = null  
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Cliente'
    ,@orderDirection varchar(4) = 'desc'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Cliente' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		 CR.IDClienteHonorario
		,ISNULL(CR.IDCliente,0) as IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'NombreComercial')) as Cliente
		,isnull(CR.Porcentaje,0.00) as Porcentaje
	    ,ISnull(CR.IncluyeIVA,0) as IncluyeIVA
	into #tempResponse
	FROM [Procom].[TblClienteHonorarios] CR with(nolock)     
		inner join [RH].[tblCatClientes] C with(nolock)
			on CR.IDCliente = C.IDCliente
	
 	WHERE
		((CR.IDClienteHonorario = @IDClienteHonorario) OR (ISNULL(@IDClienteHonorario,0) = 0))
		AND ((CR.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		AND (@query = '""' or contains(C.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteHonorario) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Cliente'			and @orderDirection = 'asc'		then Cliente end,			
		case when @orderByColumn = 'Cliente'			and @orderDirection = 'desc'	then Cliente end desc,		
		Cliente desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
