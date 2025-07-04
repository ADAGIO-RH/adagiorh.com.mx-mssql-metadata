USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [FirmaDigital].[spBorrarDocumento]
(
	@ID Varchar(255),
	@IDUsuario int
)
AS
BEGIN


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


		select @OldJSON = a.JSON from [FirmaDigital].[TblDocumentos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.ID = @ID

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[FirmaDigital].[TblDocumentos]','[FirmaDigital].[spBorrarDocumento]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  
			  DELETE [FirmaDigital].[tblDocumentosFirmantes]
			WHERE ID = @ID
			DELETE [FirmaDigital].[TblDocumentos]
			WHERE ID = @ID


		END TRY  
		BEGIN CATCH  
		DECLARE @MESSAGE VArchar(100)
			SELECT  @MESSAGE = ERROR_MESSAGE ( ) 

			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002', @CustomMessage = @MESSAGE
			return 0;
		END CATCH ;
END
GO
