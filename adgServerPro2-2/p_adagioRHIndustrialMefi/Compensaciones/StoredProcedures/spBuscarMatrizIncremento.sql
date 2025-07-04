USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Compensaciones].[spBuscarMatrizIncremento](
	@IDMatrizIncremento int = 0
	,@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Fecha'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Fecha' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


   
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	declare @tempResponse as table (
		 IDMatrizIncremento	int   
		,Fecha					Date null
		,Descripcion			Varchar(500) null
		,IDEvaluacion			int null
		,DescripcionEvaluacion  Varchar(255)
		,ValorInicial			decimal(18,2) null
		,QtyNivelesAmplitud		int null
		,ValorNivelesAmplitud	decimal(18,2) null
		,ValorCentralAmplitud	decimal(18,2) null
		,QtyNivelesProgresion	int null
		,ValorNivelesProgresion decimal(18,2) null
		,Progresiva				bit null
	);

	insert @tempResponse
	SELECT       
		S.IDMatrizIncremento 
		,S.Fecha
		,s.Descripcion		
		,isnull(s.IDEvaluacion,0) as IDEvaluacion
		,'' as  DescripcionEvaluacion 
		,isnull(s.ValorInicial			 ,0)as ValorInicial			
		,isnull(s.QtyNivelesAmplitud	,0)	as QtyNivelesAmplitud	
		,isnull(s.ValorNivelesAmplitud	 ,0)as ValorNivelesAmplitud	
		,isnull(s.ValorCentralAmplitud	 ,0)as ValorCentralAmplitud	
		,isnull(s.QtyNivelesProgresion	 ,0)as QtyNivelesProgresion	
		,isnull(s.ValorNivelesProgresion ,0)as ValorNivelesProgresion
		,isnull(s.Progresiva ,0)as Progresiva
	
	FROM [Compensaciones].[tblMatrizIncremento] S with (nolock)     
	WHERE ((S.IDMatrizIncremento = isnull(@IDMatrizIncremento,0) or isnull(@IDMatrizIncremento,0) = 0))    
		and ((@query = '""' or (contains(s.*, @query)) ) ) 
	
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDMatrizIncremento]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 		
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,	
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'asc'		then Fecha end,			
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'desc'	then Fecha end desc,
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
