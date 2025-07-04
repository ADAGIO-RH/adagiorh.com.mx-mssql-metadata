USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBorrarCatBrokers(
	@IDCatBroker int
	,@IDUsuario int
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [Procom].[tblCatBrokers] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatBroker = @IDCatBroker

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblCatBrokers]','[Procom].[spBorrarCatBrokers]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  
		  DELETE [Procom].[tblCatBrokers]
			WHERE IDCatBroker = @IDCatBroker

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
