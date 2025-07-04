USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Facturacion].[spBorrarCatConfigEmpresa]
(
	@IDConfigEmpresa int,
	@IDUsuario int
)
AS
BEGIN

DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	BEGIN TRY  

		select @OldJSON = a.JSON from Facturacion.tblCatConfigEmpresa b with(nolock)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfigEmpresa = @IDConfigEmpresa

		DELETE 	Facturacion.tblCatConfigEmpresa
		WHERE IDConfigEmpresa = @IDConfigEmpresa

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Facturacion].[tblCatConfigEmpresa]','Facturacion.tblCatConfigEmpresa','DELETE','',@OldJSON


	END TRY  
	BEGIN CATCH  
		DECLARE @Message Varchar(500)
		SELECT @Message= ERROR_MESSAGE() 
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002',@CustomMessage= @Message
			return 0;
	END CATCH ;

END
GO
