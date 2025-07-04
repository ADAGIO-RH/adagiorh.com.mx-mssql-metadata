USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBorrarUsuario]
(
	@IDUsuario int 
	,@IDUsuarioLogueado int 

)
AS
BEGIN
  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

    Select @OldJSON = (SELECT UP.*, U.IDEmpleado, U.Nombre, u.Apellido FROM Seguridad.tblUsuariosPermisos UP
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =UP.IDUsuario  
                WHERE UP.IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblUsuariosPermisos]','[Seguridad].[spBorrarUsuario]','DELETE',@NewJSON,@OldJSON


		Delete Seguridad.tblUsuariosPermisos
		Where IDUsuario = @IDUsuario

  Select @OldJSON = (SELECT PU.*,U.IDEmpleado, U.Nombre, u.Apellido  FROM Seguridad.tblPermisosUsuarioControllers PU
  inner join Seguridad.TblUsuarios U on U.IDUsuario =PU.IDUsuario  
  WHERE PU.IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosUsuarioControllers]','[Seguridad].[spBorrarUsuario]','DELETE',@NewJSON,@OldJSON

		Delete Seguridad.tblPermisosUsuarioControllers
		Where IDUsuario = @IDUsuario

  Select @OldJSON = (SELECT PE.*,U.IDEmpleado, U.Nombre, u.Apellido  FROM Seguridad.tblPermisosEspecialesUsuarios PE
  inner join Seguridad.TblUsuarios U on U.IDUsuario =PE.IDUsuario  
   WHERE PE.IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosEspecialesUsuarios]','[Seguridad].[spBorrarUsuario]','DELETE',@NewJSON,@OldJSON

		Delete Seguridad.tblPermisosEspecialesUsuarios 
		Where IDUsuario = @IDUsuario

  Select @OldJSON = (SELECT AU.*,U.IDEmpleado, U.Nombre, u.Apellido  FROM App.tblAplicacionUsuario AU
  inner join Seguridad.TblUsuarios U on U.IDUsuario =AU.IDUsuario  
  WHERE AU.IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[App].[tblAplicacionUsuario]','[Seguridad].[spBorrarUsuario]','DELETE',@NewJSON,@OldJSON


		Delete App.tblAplicacionUsuario 
		Where IDUsuario = @IDUsuario

  Select @OldJSON = (SELECT * FROM Seguridad.tblUsuarios WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblUsuarios]','[Seguridad].[spBorrarUsuario]','DELETE',@NewJSON,@OldJSON


		DELETE Seguridad.tblUsuarios
		WHERE IDUsuario = @IDUsuario
	
END
GO
