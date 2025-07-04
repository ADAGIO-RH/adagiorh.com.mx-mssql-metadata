USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBuscarCatBrokers  (
	@IDCatBroker int = 0
	,@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	 
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	declare @tempResponse as table (
			 IDCatBroker   int   
			,Codigo       varchar(20)
			,Nombre  varchar(255)    
		);

	insert @tempResponse
	SELECT
		c.IDCatBroker,
		c.Codigo,
		c.Nombre
	FROM Procom.TblCatBrokers c
	where ((c.IDCatBroker = @IDCatBroker) OR (ISNULL(@IDCatBroker,0) = 0))
	and (@query = '""' or contains(c.*, @query)) 
	

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDCatBroker]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,TotalRegistros = @TotalRegistros 
	from @tempResponse
	order by 
		case when @orderByColumn = 'Codigo'	and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'	and @orderDirection = 'desc'	then Codigo end desc,			
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'	and @orderDirection = 'desc'	then Nombre end desc,			
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
