USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarLayoutPago]        
(        
 @IDLayoutPago int = 0
 ,@PageNumber INT = 1
 ,@PageSize INT = 2147483647
 ,@query VARCHAR(4000) = '""'
 ,@orderByColumn VARCHAR(50) = 'Descripcion'
 ,@orderDirection VARCHAR(4) = 'asc'
)        
AS        
BEGIN          
	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int


	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end
	if object_id('tempdb..#tempLayoutPago') is not null drop table #tempLayoutPago;

 SELECT       
   lp.IDLayoutPago    
  ,lp.Descripcion     
  ,tlp.IDTipoLayout        
  ,tlp.TipoLayout          
  ,ISNULL(lp.IDConcepto,0) as IDConcepto        
  ,cc.Descripcion as Concepto    
  ,lp.ImporteTotal 
  ,ISNULL(lp.IDConceptoFiniquito,0) as IDConceptoFiniquito        
  ,CCF.Descripcion as ConceptoFiniquito    
  ,isnull(lp.ImporteTotalFiniquito,0) as ImporteTotalFiniquito    
  ,ROW_NUMBER()over(order by IDLayoutPago asc) as ROWNUMBER
  into #tempLayoutPago
  FROM Nomina.tblLayoutPago Lp with(nolock)      
  left join [Nomina].[tblCatTiposLayout]  tlp    
  on lp.IDTipoLayout = tlp.IDTipoLayout     
  Left Join Sat.tblCatBancos B with(nolock)        
  on tlp.IDBanco = B.IDBanco      
  left join Nomina.tblcatconceptos CC    
  on lp.IDConcepto = cc.IDConcepto      
  left join Nomina.tblcatconceptos CCF
  on lp.IDConceptoFiniquito = CCF.IDConcepto
  WHERE (LP.IDLayoutPago = @IDLayoutPago) or (@IDLayoutPago = 0)
  and (@query = '""' or contains(Lp.*, @query))

  select @TotalPaginas = CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
  from #tempLayoutPago

  select @TotalRegistros = count(IDLayoutPago) from #tempLayoutPago

  select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempLayoutPago
	order by
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'then Descripcion end desc,
		case when @orderByColumn = 'Concepto'	and @orderDirection = 'asc'	then Concepto end,			
		case when @orderByColumn = 'Concepto'	and @orderDirection = 'desc'then Concepto end desc,
		case when @orderByColumn = 'ImporteTotal'	and @orderDirection = 'asc'	then ImporteTotal end,			
		case when @orderByColumn = 'ImporteTotal'	and @orderDirection = 'desc'then ImporteTotal end desc,
		case when @orderByColumn = 'ConceptoFiniquito'	and @orderDirection = 'asc'	then ConceptoFiniquito end,			
		case when @orderByColumn = 'ConceptoFiniquito'	and @orderDirection = 'desc'then ConceptoFiniquito end desc,
		case when @orderByColumn = 'ImporteTotalFiniquito'	and @orderDirection = 'asc'	then ImporteTotalFiniquito end,			
		case when @orderByColumn = 'ImporteTotalFiniquito'	and @orderDirection = 'desc'then ImporteTotalFiniquito end desc,
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
