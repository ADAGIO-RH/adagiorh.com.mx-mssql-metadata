USE [p_adagioRHIndustrialMefi]
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
      DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);
    

 if exists (select top 1 1   
    from  Seguridad.tblPermisosUsuarioControllers  
    where IDUsuario = @IDUsuarioUsuario and IDController= @IDController)  
 begin  
 Select @OldJSON = (SELECT PC.*, U.IDEmpleado, U.Nombre, u.Apellido FROM Seguridad.tblPermisosUsuarioControllers PC 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PC.IDUsuario  
                    WHERE PC.IDUsuario = @IDUsuarioUsuario and IDController= @IDController FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

  update  Seguridad.tblPermisosUsuarioControllers  
   set IDTipoPermiso = case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end,
   PermisoPersonalizado = @PermisoPersonalizado
  where IDUsuario = @IDUsuarioUsuario and IDController= @IDController  

  Select @NewJSON = (SELECT PC.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosUsuarioControllers PC 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PC.IDUsuario  
                    WHERE PC.IDUsuario = @IDUsuarioUsuario and IDController= @IDController FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblPermisosUsuarioControllers]','[Seguridad].[spIUPermisosUsuarioControllers]','UPDATE',@NewJSON,@OldJSON

 end else  
 begin  
  insert into Seguridad.tblPermisosUsuarioControllers(IDUsuario,IDController,IDTipoPermiso,PermisoPersonalizado)  
  select @IDUsuarioUsuario,@IDController,case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end, @PermisoPersonalizado 

   Select @NewJSON =(SELECT PC.*, U.IDEmpleado,U.Nombre, u.Apellido FROM Seguridad.tblPermisosUsuarioControllers PC 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PC.IDUsuario  
                    WHERE PC.IDUsuario = @IDUsuarioUsuario and PC.IDController= @IDController FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)



 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblPermisosUsuarioControllers]','[Seguridad].[spIUPermisosUsuarioControllers]','INSERT',@NewJSON,''

 end;
GO
