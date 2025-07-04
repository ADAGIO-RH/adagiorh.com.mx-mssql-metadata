USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    PROCEDURE [Seguridad].[spBorrarToken](
	@IDToken int,
	@IDUsuario int
)
AS
BEGIN
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


		select @OldJSON = a.JSON from [Seguridad].[tblTokens] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDToken = @IDToken

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblTokens]','[Seguridad].[spBorrarToken]','DELETE',@NewJSON,@OldJSON

		BEGIN TRY  
		  DELETE [Seguridad].[tblTokens]
			WHERE IDToken = @IDToken

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;

END
GO
