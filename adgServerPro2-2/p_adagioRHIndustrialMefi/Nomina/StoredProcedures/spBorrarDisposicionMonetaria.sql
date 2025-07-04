USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Nomina].[spBorrarDisposicionMonetaria]
(
	@IDDisposicionMonetaria int
	 ,@IDUsuario int    
)
AS
BEGIN


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	
		select @NewJSON = a.JSON from [Nomina].[tblDisposicionMonetaria] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDisposicionMonetaria = @IDDisposicionMonetaria

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblDisposicionMonetaria]','[Nomina].[spBorrarDisposicionMonetaria]','DELETE',@NewJSON,''

		BEGIN TRY  
		  DELETE [Nomina].[tblDisposicionMonetaria]
			WHERE IDDisposicionMonetaria = @IDDisposicionMonetaria
		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
