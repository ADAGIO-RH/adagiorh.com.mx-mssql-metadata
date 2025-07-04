USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarCatCesantiaVejezPatronalDetalle](
	@IDCesantiaVejezPatronalDetalle int = 0
	,@IDCesantiaVejezPatronal int = 0
	,@IDUsuario int = null      
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Desde'
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
			 IDCesantiaVejezPatronalDetalle int
			,IDCesantiaVejezPatronal int
			,Desde decimal(18,2)
			,Hasta decimal(18,2)
			--,MinimoGeneral decimal(18,2)
			--,MaximoGeneral decimal(18,2)
			--,MinimoFronterizo decimal(18,2)
			--,MaximoFronterizo decimal(18,2)
			,CuotaPatronal decimal(18,6)
    ); 

	INSERT @tempResponse    
	Select    
		IDCesantiaVejezPatronalDetalle
		,IDCesantiaVejezPatronal
		,Desde
		,Hasta
		--,MinimoGeneral
		--,MaximoGeneral
		--,MinimoFronterizo
		--,MaximoFronterizo
		,CuotaPatronal
	From IMSS.tblCatCesantiaVejezPatronalDetalle  with(nolock)    
	where ((IDCesantiaVejezPatronal = @IDCesantiaVejezPatronal) or (isnull(@IDCesantiaVejezPatronal,0) = 0))
		and ((IDCesantiaVejezPatronalDetalle = @IDCesantiaVejezPatronalDetalle) or (isnull(@IDCesantiaVejezPatronalDetalle,0) = 0))
	order by Desde asc   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDCesantiaVejezPatronalDetalle) as int) from @tempResponse		

	select *
		,TotalPages = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        ,TotalRows=@TotalRegistros
	from @tempResponse
	order by 
		case when @orderByColumn = 'Desde'	and @orderDirection = 'asc'		then Desde end,			
		case when @orderByColumn = 'Desde'	and @orderDirection = 'desc'	then Desde end desc,					
		Desde asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
