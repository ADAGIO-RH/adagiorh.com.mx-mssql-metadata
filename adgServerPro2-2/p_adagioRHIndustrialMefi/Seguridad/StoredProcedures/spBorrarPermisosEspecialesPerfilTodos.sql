USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure  [Seguridad].[spBorrarPermisosEspecialesPerfilTodos]
(
	@IDPerfil int,
	@IDUrl int,
    @IDUsuario int
)
AS
BEGIN
DECLARE @OldJSON Varchar(Max);

    Select @OldJSON = (SELECT * FROM Seguridad.tblPermisosEspecialesPerfiles WHERE IDPerfil = @IDPerfil  FOR JSON PATH)

EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblPermisosEspecialesPerfiles]','[Seguridad].[spBorrarPermisosEspecialesPerfilTodos]','DELETE','',@OldJSON

	DELETE PEU
	from Seguridad.tblPermisosEspecialesPerfiles PEU
		inner join app.tblCatPermisosEspeciales pe
			on pe.IDPermiso = PEU.IDPermiso
	WHERE PEU.IDPerfil = @IDPerfil
	and pe.IDUrlParent = @IDUrl
END
GO
