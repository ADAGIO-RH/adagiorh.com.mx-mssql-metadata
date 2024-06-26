USE [p_adagioRHAC]
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
 ,@PermisoPersonalizado bit = 0
 ) as  
  
 if exists (select top 1 1   
    from  Seguridad.tblPermisosUsuarioControllers  
    where IDUsuario = @IDUsuarioUsuario and IDController= @IDController)  
 begin  
  update  Seguridad.tblPermisosUsuarioControllers  
   set IDTipoPermiso = case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end,
   PermisoPersonalizado = @PermisoPersonalizado
  where IDUsuario = @IDUsuarioUsuario and IDController= @IDController  
 end else  
 begin  
  insert into Seguridad.tblPermisosUsuarioControllers(IDUsuario,IDController,IDTipoPermiso,PermisoPersonalizado)  
  select @IDUsuarioUsuario,@IDController,case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end, @PermisoPersonalizado 
 end;
GO
