USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [IMSS].[spBuscarCatCesantiaVejezPatronal]
(
	@IDCesantiaVejezPatronal int = 0
	,@IDUsuario int = null      
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'FechaInicial'
    ,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN

	SET FMTONLY OFF;

    declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end

	declare @tempResponse as table (
			    IDCesantiaVejezPatronal  int   
                ,FechaInicial DATE
                ,FechaFinal  DATE
                ,Descripcion  varchar(MAX)
    );

	INSERT @tempResponse    
	Select    
		IDCesantiaVejezPatronal    
		,FechaInicial    
		,FechaFinal    
		,Descripcion    
	From IMSS.tblCatCesantiaVejezPatronal  with(nolock)    
	where ((IDCesantiaVejezPatronal = @IDCesantiaVejezPatronal) or (isnull(@IDCesantiaVejezPatronal,0) = 0))
	order by FechaInicial asc   
	

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDCesantiaVejezPatronal) as int) from @tempResponse		

	select *
		,TotalPages = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        ,TotalRows=@TotalRegistros
	from @tempResponse
	order by 
		case when @orderByColumn = 'FechaInicial'			and @orderDirection = 'asc'		then FechaInicial end,			
		case when @orderByColumn = 'FechaInicial'			and @orderDirection = 'desc'	then FechaInicial end desc,					
		FechaInicial asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
