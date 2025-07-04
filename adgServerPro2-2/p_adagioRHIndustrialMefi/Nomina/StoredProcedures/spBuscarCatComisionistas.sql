USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Nomina.spBuscarCatComisionistas
(
	@IDCatComisionista int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Identificador'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
		SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	 
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

	declare @tempResponse as table (
			 IDCatComisionista   int   
			,Identificador       varchar(255)
			,NombreCompleto  varchar(500)    
		);

	insert @tempResponse
	SELECT
		c.IDCatComisionista,
		c.Identificador,
		c.NombreCompleto
	FROM Nomina.tblCatComisionistas c
	where (@query = '""' or contains(c.*, @query)) 
	  order by c.Identificador asc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDCatComisionista]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Identificador'			and @orderDirection = 'asc'		then Identificador end,			
		case when @orderByColumn = 'Identificador'			and @orderDirection = 'desc'	then Identificador end desc,			
		case when @orderByColumn = 'NombreCompleto'	and @orderDirection = 'asc'		then NombreCompleto end,			
		case when @orderByColumn = 'NombreCompleto'	and @orderDirection = 'desc'	then NombreCompleto end desc,			
		Identificador asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
