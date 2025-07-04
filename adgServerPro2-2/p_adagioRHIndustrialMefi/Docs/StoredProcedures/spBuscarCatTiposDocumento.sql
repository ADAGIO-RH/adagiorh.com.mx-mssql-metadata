USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spBuscarCatTiposDocumento]
(
	@IDTipoDocumento int = 0
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
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end

	declare @tempTipoDocumento as table (
		 IDTipoDocumento   int   
		,Descripcion  varchar(255)    
	);

	insert into @tempTipoDocumento
	SELECT td.IDTipoDocumento
		,td.Descripcion
	FROM Docs.tblCatTiposDocumento td
	WHERE ((IDTipoDocumento = @IDTipoDocumento) OR (ISNULL(@IDTipoDocumento,0) = 0))
		and (@query = '""' or contains(td.*, @query)) 



	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempTipoDocumento

	select @TotalRegistros = cast(COUNT(IDTipoDocumento) as decimal(18,2)) from @tempTipoDocumento	
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempTipoDocumento
	order by 
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END;
GO
