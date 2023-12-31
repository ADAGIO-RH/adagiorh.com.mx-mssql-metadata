USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTiposPrestamo](  
	@IDTipoPrestamo int = null,
	@SoloTiposConConcepto bit = 0
)  
AS  
BEGIN  
	SELECT 
		p.IDTipoPrestamo  
		,p.Codigo  
		,p.Descripcion  
		,isnull(p.IDConcepto,0) as IDConcepto  
		,c.Codigo +' - '+ c.Descripcion as DescripcionConcepto  
		,ROW_NUMBER()over(ORDER BY P.IDTipoPrestamo)as ROWNUMBER  
	FROM Nomina.tblCatTiposPrestamo p   
		left join Nomina.tblCatConceptos c  
			on p.IDConcepto = c.IDConcepto  
	WHERE (IDTipoPrestamo = @IDTipoPrestamo) or (@IDTipoPrestamo is null) 
		and (isnull(p.IDConcepto,0) > 0 or @SoloTiposConConcepto = 0)
END
GO
