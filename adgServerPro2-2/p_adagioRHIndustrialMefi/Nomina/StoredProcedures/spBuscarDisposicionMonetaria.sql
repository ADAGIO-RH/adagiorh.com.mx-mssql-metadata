USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Nomina].[spBuscarDisposicionMonetaria]    
(    
 	  @IDDisposicionMonetaria int = null
 	 ,@IDTipoDisposicionMonetaria int = null
     ,@IDPeriodo int = null
	 ,@IDUsuario int = null    
	 ,@PageNumber	int = 1
	 ,@PageSize		int = 2147483647
	 ,@query			varchar(100) = '""'
	 ,@orderByColumn	varchar(50) = 'FechaTransferencia'
	 ,@orderDirection varchar(4) = 'asc'
)    
AS    
BEGIN    
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaTransferencia' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		 d.IDDisposicionMonetaria    
		,d.IDTipoDisposicionMonetaria    
		,td.Descripcion as TipoDisposicionMonetaria
		,d.IDPeriodo as IDPeriodo
		,p.ClavePeriodo as ClavePeriodo
		,p.Descripcion as Periodo
		,d.FechaTransferencia
		,d.Monto
	into #tempResponse
	FROM [Nomina].[tblDisposicionMonetaria] d with(nolock)     
		inner join [Nomina].tblCatTipoDisposicionMonetaria td with(nolock)
			on d.IDTipoDisposicionMonetaria = td.IDTipoDisposicionMonetaria
		inner join Nomina.tblCatPeriodos p with(nolock)
			on p.IDPeriodo = d.IDPeriodo
	WHERE

		( (d.IDTipoDisposicionMonetaria = @IDTipoDisposicionMonetaria or isnull(@IDTipoDisposicionMonetaria,0) =0))  and
		( (d.IDPeriodo = @IDPeriodo or isnull(@IDPeriodo,0) =0)) and
		( (d.IDDisposicionMonetaria = @IDDisposicionMonetaria or isnull(@IDDisposicionMonetaria,0) =0)) 
		
	ORDER BY d.FechaTransferencia ASC    

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDDisposicionMonetaria) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'FechaTransferencia'			and @orderDirection = 'asc'		then FechaTransferencia end,			
		case when @orderByColumn = 'FechaTransferencia'			and @orderDirection = 'desc'	then FechaTransferencia end desc,		
		FechaTransferencia asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
