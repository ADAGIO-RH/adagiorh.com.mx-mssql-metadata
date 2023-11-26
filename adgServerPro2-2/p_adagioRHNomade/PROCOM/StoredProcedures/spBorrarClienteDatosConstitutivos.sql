USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE PROCOM.spBorrarClienteDatosConstitutivos(
	@IDClienteDatosConstitutivos int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max),
	@IDCliente int

	BEGIN TRY  
		

		select @OldJSON = a.JSON from [Procom].[tblClienteDatosConstitutivos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteDatosConstitutivos = @IDClienteDatosConstitutivos

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteDatosConstitutivos]','[Procom].[spBorrarClienteDatosConstitutivos]','DELETE','',@OldJSON

		Delete [Procom].[tblClienteDatosConstitutivos]  
		where IDClienteDatosConstitutivos = @IDClienteDatosConstitutivos

	END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
	END CATCH ;
END
GO
