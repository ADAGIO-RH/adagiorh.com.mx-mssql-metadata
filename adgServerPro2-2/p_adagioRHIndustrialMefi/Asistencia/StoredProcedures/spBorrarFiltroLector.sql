USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBorrarFiltroLector](    
 @IDFiltroLector int    
 ,@IDUsuarioLogin int    
)    
as    
 declare @IDLector int = 0;    
    
 select @IDLector = IDLector    
 from [Asistencia].[tblFiltrosLector]    
 where IDFiltroLector   = @IDFiltroLector  
 
 Delete [Asistencia].[tblFiltrosLector]    
 where IDFiltroLector   = @IDFiltroLector 
 
        
 exec [Asistencia].[spAsignarEmpleadosALectoresPorFiltro] @IDLector = @IDLector, @IDUsuarioLogin = @IDUsuarioLogin
GO
