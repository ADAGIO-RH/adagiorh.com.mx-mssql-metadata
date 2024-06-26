USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatClasificacionesCorporativas]  
(
    @IDClasificacionCorporativa int = null,  
 @ClasificacionCorporativa Varchar(50) = null,
 @IDUsuario int = null  
  ,@PageNumber	int = 1
 ,@PageSize		int = 2147483647
 ,@query			varchar(100) = '""'
 ,@orderByColumn	varchar(50) = 'Descripcion'
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

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
	IF OBJECT_ID('tempdb..#TempClasificacionesCorporativas') IS NOT NULL DROP TABLE #TempClasificacionesCorporativas

		set @query = case 
			when @query is null then '""' 
			when @query = '' then '""'
			when @query = '""' then '""'
		else '"'+@query + '*"' end

	select ID 
	Into #TempClasificacionesCorporativas
	from Seguridad.tblFiltrosUsuarios with(nolock)  
	where IDUsuario = @IDUsuario and Filtro = 'ClasificacionesCorporativas'
 
	select  
		IDClasificacionCorporativa  
		,Codigo  
		,Descripcion  
		,CuentaContable  
		,ROW_NUMBER()over(ORDER BY IDClasificacionCorporativa)as ROWNUMBER  
			into #tempResponse
	from RH.tblCatClasificacionesCorporativas  with(nolock)  
	where 
	--(Codigo like @ClasificacionCorporativa+'%') OR(Descripcion like @ClasificacionCorporativa+'%') OR(@ClasificacionCorporativa is null)  
	--	and ( ( IDClasificacionCorporativa in  ( select ID from #TempClasificacionesCorporativas) or not Exists(select ID from #TempClasificacionesCorporativas)) 
	--               AND                
	--           )
			(IDClasificacionCorporativa=@IDClasificacionCorporativa or isnull(@IDClasificacionCorporativa,0) =0)
				and (@query = '""' or contains(RH.tblCatClasificacionesCorporativas.*, @query)) 
	order by Descripcion asc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempResponse

	select @TotalRegistros = COUNT(IDClasificacionCorporativa) from #TempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempResponse
	order by 
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,		
		Descripcion asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
   
END
GO
