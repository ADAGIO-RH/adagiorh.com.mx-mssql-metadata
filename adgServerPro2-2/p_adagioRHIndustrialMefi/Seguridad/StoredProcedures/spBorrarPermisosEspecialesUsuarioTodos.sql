USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure  [Seguridad].[spBorrarPermisosEspecialesUsuarioTodos]
(
	@IDUsuario int,
	@IDUsuarioLogin int,
	@IDUrl int
)
AS
BEGIN
DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

    Select @OldJSON = LEFT (
        (SELECT PE.*, U.IDEmpleado, U.Nombre, u.Apellido  FROM Seguridad.tblPermisosEspecialesUsuarios PE 
     inner join Seguridad.TblUsuarios U on U.IDUsuario =PE.IDUsuario  
    WHERE PE.IDUsuario = @IDUsuario FOR JSON PATH),
     8000);

EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblPermisosEspecialesUsuarios]','[Seguridad].[spBorrarPermisosEspecialesUsuarioTodos]','DELETE',@NewJSON,@OldJSON

	DELETE PEU
	from Seguridad.tblPermisosEspecialesUsuarios PEU
		inner join app.tblCatPermisosEspeciales pe
			on pe.IDPermiso = PEU.IDPermiso
	WHERE PEU.IDUsuario = @IDUsuario
	and pe.IDUrlParent = @IDUrl
END
GO
