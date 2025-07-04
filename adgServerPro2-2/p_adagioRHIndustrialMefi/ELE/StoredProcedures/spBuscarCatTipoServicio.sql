USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ELE].[spBuscarCatTipoServicio](    
	@IDTipoServicio int = null   
	,@IDUsuario int = null  
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Descripcion'
	,@orderDirection varchar(4) = 'asc'    
)    
AS    
BEGIN    
	SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	
	IF OBJECT_ID('tempdb..#TempTiposServicios') IS NOT NULL DROP TABLE #TempTiposServicios
    	
  
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	SELECT     
		c.IDTipoServicio,
        c.Descripcion				
	into #TempTiposServicios
	FROM ELE.[tblCatTiposServicios] C  with(nolock)   		 
	WHERE (c.IDTipoServicio = @IDTipoServicio ) OR (isnull(@IDTipoServicio,0) = 0)    		
		and (@query = '""' or Descripcion like  '"%'+@query+'%"') 
	
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempTiposServicios

	select @TotalRegistros = cast(COUNT([IDTipoServicio]) as decimal(18,2)) from #TempTiposServicios		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,@TotalRegistros as TotalRegistros
	from #TempTiposServicios
	order by 
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,					
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
