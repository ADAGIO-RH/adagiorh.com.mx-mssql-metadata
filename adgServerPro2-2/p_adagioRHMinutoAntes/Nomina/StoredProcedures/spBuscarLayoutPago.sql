USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarLayoutPago]        
(        
 @IDLayoutPago int = 0        
)        
AS        
BEGIN          
        
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
END
GO
