USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE proc [Seguridad].[spIUPermisosUsuarioControllers](  
  @IDUsuarioUsuario int   
 ,@IDController int   
 ,@IDTipoPermiso nvarchar(10)   
 ,@IDUsuario int   
 ) as  
  
 if exists (select top 1 1   
    from  Seguridad.tblPermisosUsuarioControllers  
    where IDUsuario = @IDUsuarioUsuario and IDController= @IDController)  
 begin  
  update  Seguridad.tblPermisosUsuarioControllers  
   set IDTipoPermiso = case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end  
  where IDUsuario = @IDUsuarioUsuario and IDController= @IDController  
 end else  
 begin  
  insert into Seguridad.tblPermisosUsuarioControllers(IDUsuario,IDController,IDTipoPermiso)  
  select @IDUsuarioUsuario,@IDController,case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end  
 end;
GO
