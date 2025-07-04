USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-09
-- Description:	stored procedure para buscar 
-- exec [Reclutamiento].[spBuscarPlantillas]
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBuscarPlantillas]
	(
		@IDPlantilla int = null

		,@PageNumber	int = 1
		,@PageSize		int = 2147483647
		,@query			varchar(100) = '""'
		,@orderByColumn	varchar(50) = 'Orden'
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
				else @query  end


	declare @tempResponse as table (
				IDPlantilla INT, 
				Descripcion varchar(50), 
				Contenido text,
				Asunto text
    );

    INSERT @tempResponse    
    select V.IDPlantilla, V.Descripcion, Contenido, V.Asunto
    from[Reclutamiento].[tblPlantillas] AS V    
    where (V.IDPlantilla = @IDPlantilla OR @IDPlantilla IS NUll or @IDPlantilla=0) 
			and (@query = '""' or V.Descripcion like '%'+@query+'%')
    order by V.IDPlantilla

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDPlantilla) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Orden'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Orden'			and @orderDirection = 'desc'	then Descripcion end desc,					
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
