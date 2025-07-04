USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatDatosExtraClientes]
(
	@IDCatDatoExtraCliente int = 0
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
	    ,@TotalRegistros int
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	 
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

	declare @tempResponse as table (
		 IDCatDatoExtraCliente   int   
		,Nombre       varchar(255)
		,Descripcion  varchar(500)    
		,TipoDato varchar(50)      
		,ROWNUMBER int
	);

	insert @tempResponse
	SELECT 
		IDCatDatoExtraCliente
		,Nombre
		,Descripcion
		,TipoDato
		,   ROW_NUMBER()over(ORDER BY IDCatDatoExtraCliente)as ROWNUMBER
	FROM RH.tblCatDatosExtraClientes s
	where (IDCatDatoExtraCliente = @IDCatDatoExtraCliente) OR (@IDCatDatoExtraCliente = 0)
	and (@query = '""' or contains(s.*, @query)) 
	ORDER BY Nombre

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDCatDatoExtraCliente]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from @tempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		case when @orderByColumn = 'TipoDato'	and @orderDirection = 'asc'		then TipoDato end,		
		case when @orderByColumn = 'TipoDato'	and @orderDirection = 'desc'	then TipoDato end desc,					
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
