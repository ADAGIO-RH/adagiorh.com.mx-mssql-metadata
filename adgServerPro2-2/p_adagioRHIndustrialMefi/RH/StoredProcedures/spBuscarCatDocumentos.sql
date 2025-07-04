USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatDocumentos]    
(    
 @IDDocumento int = null    
)    
AS    
BEGIN    
 SELECT     
  IDDocumento    
  ,Codigo  
  ,Descripcion     
  ,Template    
  ,Plantilla    
  ,Isnull(EsContrato,0) as EsContrato
  ,EsResponsiva
 FROM [RH].[tblCatDocumentos]    
 WHERE IDDocumento = @IDDocumento or @IDDocumento is null    
END
GO
