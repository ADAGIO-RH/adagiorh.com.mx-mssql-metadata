USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBorrarCatFiltroUsuario](    
 @IDCatFiltroUsuario int    
 ,@IDUsuarioCreo int    
)    
as    
 declare @IDUsuario int = 0;    
    
 select @IDUsuario = IDUsuario    
 from [Seguridad].[tblCatFiltrosUsuarios]    
 where IDCatFiltroUsuario= @IDCatFiltroUsuario
 
  Delete [Seguridad].[tblCatFiltrosUsuarios]
 where IDCatFiltroUsuario = @IDCatFiltroUsuario 

 --Delete [Seguridad].[tblFiltrosUsuarios]
 --where IDCatFiltroUsuario = @IDCatFiltroUsuario  
 
        
 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuarioCreo
GO
