USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Nomina].[spBorrarCatTipoDisposicionMonetaria]
(
	@IDTipoDisposicionMonetaria int
	 ,@IDUsuario int    
)
AS
BEGIN


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF EXISTS(Select Top 1 1 from Nomina.tblDisposicionMonetaria where IDTipoDisposicionMonetaria = @IDTipoDisposicionMonetaria)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

		select @NewJSON = a.JSON from [Nomina].[tblCatTipoDisposicionMonetaria] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoDisposicionMonetaria = @IDTipoDisposicionMonetaria

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblCatTipoDisposicionMonetaria]','[Nomina].[spBorrarCatTipoDisposicionMonetaria]','DELETE',@NewJSON,''

		BEGIN TRY  
		  DELETE [Nomina].[tblCatTipoDisposicionMonetaria]
			WHERE IDTipoDisposicionMonetaria = @IDTipoDisposicionMonetaria
		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
