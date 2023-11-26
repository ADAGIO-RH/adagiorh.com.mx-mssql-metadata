USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Procom.spBorrarProtocoloIX(
	@IDProtocoloIX int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	
		select @OldJSON = a.JSON from [Procom].[tblProtocoloIX] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDProtocoloIX = @IDProtocoloIX

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblProtocoloIX]','[RH].[spBorrarProtocoloIX]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  
		  DELETE [Procom].[tblProtocoloIX]
			WHERE IDProtocoloIX = @IDProtocoloIX

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
