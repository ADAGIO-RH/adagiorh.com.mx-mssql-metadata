USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBorrarCatPerfiles]
(
	@IDPerfil int 
	,@IDUsuario int
)
AS
BEGIN


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [Seguridad].[tblCatPerfiles] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDPerfil = @IDPerfil

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblCatPerfiles]','[Seguridad].[spBorrarCatPerfiles]','DELETE',@NewJSON,@OldJSON

	BEGIN TRY  
		Delete Seguridad.tblCatPerfiles
		Where (IDPerfil = @IDPerfil)
	END TRY  
	BEGIN CATCH  
	EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END CATCH ;
END
GO
