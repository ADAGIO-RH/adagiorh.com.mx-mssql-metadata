USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-06-03
-- Description:	sp para buscar los aspectos a evaluar
--				relacionados a una plaza
-- [Reclutamiento].[spBuscar] 1
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBuscarAspectosEvaluarPlazas]
	(
		@IDPlaza int = 0

		,@PageNumber	int = 1
		,@PageSize		int = 2147483647
		,@query			varchar(100) = '""'
		,@orderByColumn	varchar(50) = 'Orden'
		,@orderDirection varchar(4) = 'asc'
	)
AS
BEGIN

declare 
	 @TotalPaginas int = 0
	 ,@TotalRegistros decimal(18,2) = 0.00;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;
					
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query end

	declare @tempResponse as table (
				IDAspectoEvaluar INT, 
				IDPlaza int,
				Descripcion varchar(200),
				Detalles text
		);

	insert @tempResponse
	SELECT 
		IDAspectoEvaluar, IDPlaza, Descripcion, Detalles
	FROM
		Reclutamiento.tblAspectosEvaluar
	WHERE IDPlaza = @IDPlaza

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDAspectoEvaluar) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Orden'			and @orderDirection = 'asc'		then IDAspectoEvaluar end,			
		case when @orderByColumn = 'Orden'			and @orderDirection = 'desc'	then IDAspectoEvaluar end desc,					
		IDAspectoEvaluar asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
