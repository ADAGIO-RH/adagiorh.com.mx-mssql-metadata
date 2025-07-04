USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Docs].[spBorrarFiltroDocumentos](    
 @IDFiltrosDocumentos int    
 ,@IDUsuarioLogin int    
)    
as    
 declare @IDDocumento int = 0;    
    
 select @IDDocumento = IDDocumento    
 from [Docs].[tblFiltrosDocumentos]    
 where IDFiltrosDocumentos  = @IDFiltrosDocumentos  
 
 Delete [Docs].[tblFiltrosDocumentos]
 where IDFiltrosDocumentos  = @IDFiltrosDocumentos  
 
exec [Docs].[spAsignarEmpleadosADocumentosPorFiltro] @IDDocumento = @IDDocumento
GO
