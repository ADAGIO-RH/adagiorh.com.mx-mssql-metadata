USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatTiposPrestacionesDetalle]
(
	@IDTipoPrestacion int 
	,@IDUsuario int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Antiguedad'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;


	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
    
		set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+ @query + '*"' end

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Antiguedad' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	SELECT 
		IDTipoPrestacionDetalle
		,IDTipoPrestacion
		,isnull(Antiguedad,0) as Antiguedad
		,isnull(DiasAguinaldo,0) as DiasAguinaldo
		,isnull(DiasVacaciones,0)as DiasVacaciones
		,isnull(PrimaVacacional,0.0)as PrimaVacacional
		,isnull(PorcentajeExtra,0.0)as PorcentajeExtra
		,isnull(DiasExtras,0)as DiasExtras
		,isnull(Factor,0.00000)as Factor
	into #TempResponse
	FROM [RH].[tblCatTiposPrestacionesDetalle]
	WHERE (IDTipoPrestacion = @IDTipoPrestacion) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDTipoPrestacionDetalle) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Antiguedad'			and @orderDirection = 'asc'		then Antiguedad end,		
		case when @orderByColumn = 'Antiguedad'			and @orderDirection = 'desc'	then Antiguedad end desc,
		Antiguedad asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
		
END
GO
