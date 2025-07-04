USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBorrarGrupoFiltrosLector](    
 @IDGrupoFiltrosLector int    
 ,@IDUsuarioCreo int    
)    
as    
 declare @IDLector int = 0;    
    
 select @IDLector = IDLector    
 from [Asistencia].[tblGrupoFiltrosLector]    
 where IDGrupoFiltrosLector= @IDGrupoFiltrosLector
 
 Delete [Asistencia].[tblFiltrosLector]
 where IDGrupoFiltrosLector = @IDGrupoFiltrosLector
 
  Delete [Asistencia].[tblGrupoFiltrosLector]
 where IDGrupoFiltrosLector = @IDGrupoFiltrosLector
     
  exec [Asistencia].[spAsignarEmpleadosALectoresPorFiltro] @IDLector = @IDLector, @IDUsuarioLogin = @IDUsuarioCreo
GO
