USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Docs].[spBuscarFiltrosDocumentosDistinct](  
 @IDFiltrosDocumentos int = 0  
 ,@IDDocumento int = 0   
) as  
 select    
  distinct   
   IDFiltrosDocumentos = case when Filtro = 'Usuario' then 0  
       else IDFiltrosDocumentos  
       end  
   ,IDDocumento  
   ,Filtro = case when Filtro = 'Usuario' then Filtro  
       else coalesce(Filtro,'')+ ' | '+coalesce(Descripcion,'')  
       end  
 from [Docs].[tblFiltrosDocumentos]  
 where (IDFiltrosDocumentos = @IDFiltrosDocumentos or @IDFiltrosDocumentos = 0) and (IDDocumento = @IDDocumento or @IDDocumento = 0)
GO
