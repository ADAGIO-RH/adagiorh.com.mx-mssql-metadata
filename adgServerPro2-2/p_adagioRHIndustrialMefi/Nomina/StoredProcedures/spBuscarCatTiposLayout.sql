USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarCatTiposLayout]  
(  
 @IDTipoLayout int = 0  
)  
AS  
BEGIN    
  
 SELECT  
  IDTipoLayout  
  ,TipoLayout  
  ,ISNULL(TL.IDBanco,0) as IDBanco  
  ,B.Descripcion as Banco  
  ,TL.NombreProcedimiento  
  ,ROW_NUMBER()over(order by IDTipoLayout asc) as ROWNUMBER  
  FROM Nomina.tblCatTiposLayout TL with(nolock)  
   Left Join Sat.tblCatBancos B with(nolock)  
    on TL.IDBanco = B.IDBanco  
   
  WHERE (TL.IDTipoLayout = @IDTipoLayout) or (@IDTipoLayout = 0)   
END
GO
