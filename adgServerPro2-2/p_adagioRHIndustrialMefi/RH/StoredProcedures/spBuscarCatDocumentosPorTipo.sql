USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatDocumentosPorTipo]  
(  
 @EsContrato bit  
)  
AS  
BEGIN  
 SELECT   
  IDDocumento  
  ,Codigo
  ,Descripcion   
  ,Template  
  ,Plantilla  
  ,isnull(EsContrato,0) as EsContrato
  ,EsResponsiva
 FROM [RH].[tblCatDocumentos]  
 WHERE EsContrato = @EsContrato
END
GO
