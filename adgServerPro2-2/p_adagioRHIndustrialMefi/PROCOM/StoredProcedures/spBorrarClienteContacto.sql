USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE PROCOM.spBorrarClienteContacto(
	@IDClienteContacto int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max),
	@IDCliente int

	BEGIN TRY  
		select @OldJSON = a.JSON from [Procom].[tblClienteContacto] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteContacto = @IDClienteContacto

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteContacto]','[Procom].[spBorrarClienteContacto]','DELETE','',@OldJSON

		Delete [Procom].[tblClienteContacto]  
		where IDClienteContacto = @IDClienteContacto
	END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
	END CATCH ;
END
GO
