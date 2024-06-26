USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Facturacion.spBuscarCatConfigEmpresa  
(  
 @IDConfigEmpresa int = null  
)  
AS  
BEGIN  
 Select   
   CE.IDConfigEmpresa  
   ,isnull(CE.IDEmpresa,0) as IDEmpresa  
   ,E.NombreComercial as Empresa  
   ,E.RFC  
   ,CE.Usuario  
   ,CE.Password  
   ,CE.PasswordKey
   ,CE.Token
      
   --,isnull(CE.IDPack,0) as IDPack  
   --,p.NombrePack  
 From Facturacion.tblCatConfigEmpresa CE  
  LEFT join RH.tblEmpresa E  
   on CE.IDEmpresa = E.IDEmpresa  
  --LEFT Join Facturacion.tblCatPacks P  
  -- on CE.IDPack = P.IDPack  
 WHERE (CE.IDConfigEmpresa = @IDConfigEmpresa) OR (@IDConfigEmpresa is null)  
    
END
GO
