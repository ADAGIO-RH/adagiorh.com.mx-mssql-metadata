USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [FirmaDigital].[spIUDocumentos]
(
	 @Id VARCHAR(255) 
	,@IDTipoDocumento INT = 0
	,@Nombre VARCHAR(255)	
    ,@ExternalId VARCHAR(255) = null
    ,@MessageForSigners VARCHAR(MAX) = null
    ,@RemindEvery INT = null
    ,@OriginalHash VARCHAR(255) = null
    ,@FileName VARCHAR(255) = null
    ,@SignedByAll bit = null
    ,@Signed bit = null
    ,@SignedAt DATETIME = null
    ,@DaysToExpire INT = null
    ,@ExpiresAt    DATETIME = NULL
    ,@CreatedAt    DATETIME = NULL    
    ,@CallbackUrl VARCHAR(255) = null
    ,@SignCallbackUrl VARCHAR(255) = null
    ,@File VARCHAR(MAX) = null
    ,@FileDownload VARCHAR(255) = null
    ,@FileSigned VARCHAR(255) = null
    ,@FileSignedDownload VARCHAR(255) = null
    ,@FileZipped VARCHAR(255) = null
    ,@ManualClose bit = null
    ,@SendMail bit = null
	,@State Varchar(255) = null
    ,@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	SET @IDUsuario = CASE WHEN ISNULL(@IDUsuario,0) = 0 THEN 1 ELSE @IDUsuario end

	set @Nombre = UPPER(@Nombre)


	IF NOT EXISTS(SELECT TOP 1 1 FROM [FirmaDigital].[TblDocumentos] with(nolock) WHERE (ID = @Id))
	BEGIN
        IF(isnull(@IDTipoDocumento,0) = 0)
	    BEGIN
	    	 RAISERROR('No se esta recibiendo ningun parametro de referencia de este documento.[IDTipoDocumento]', 16, 1)
	    	 RETURN;
	    END

		INSERT INTO [FirmaDigital].[TblDocumentos]
				   (
						 Id
						,IDTipoDocumento
						,Nombre						
						,ExternalId
						,MessageForSigners
						,RemindEvery
						,OriginalHash
						,[FileName]
						,SignedByAll
						,Signed
						,SignedAt
						,CallbackUrl
						,SignCallbackUrl
						,[File]
						,FileDownload
						,FileSigned
						,FileSignedDownload
						,FileZipped
						,ManualClose
						,SendMail
						,IDUsuario
                        ,DaysToExpire
                        ,ExpiresAt
                        ,CreatedAt						
						,[State]
				   )
			 VALUES
				   (
					 @Id
					,@IDTipoDocumento
					,@Nombre					
					,@ExternalId
					,@MessageForSigners
					,isnull(@RemindEvery,0)
					,@OriginalHash
					,@FileName
					,isnull(@SignedByAll,0)
					,isnull(@Signed,0)
					,@SignedAt
					,@CallbackUrl
					,@SignCallbackUrl
					,@File
					,@FileDownload
					,@FileSigned
					,@FileSignedDownload
					,@FileZipped
					,isnull(@ManualClose,0)
					,isnull(@SendMail	,0)
					,CASE WHEN isnull(@IDUsuario,0) = 0 THEN NULL ELSE @IDUsuario END
					,isnull(@DaysToExpire,0)
                    ,@ExpiresAt
                    ,@CreatedAt                    
					,@State
				   )

		select @NewJSON = a.JSON from [FirmaDigital].[TblDocumentos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.id = @id

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[FirmaDigital].[TblDocumentos]','[FirmaDigital].[spIUDocumentos]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [FirmaDigital].[TblDocumentos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.id = @id

		UPDATE [FirmaDigital].[TblDocumentos]
		   SET 				
				 DaysToExpire			= isnull(@DaysToExpire,0)
                ,ExpiresAt              = @ExpiresAt
                ,CreatedAt              = @CreatedAt
				,RemindEvery			= isnull(@RemindEvery,0)
				,OriginalHash			= @OriginalHash
				,SignedByAll			= isnull(@SignedByAll,0)
				,Signed					= isnull(@Signed,0)
				,SignedAt				= @SignedAt
				,[File]					= @File
				,FileDownload			= @FileDownload
				,FileSigned				= @FileSigned
				,FileSignedDownload		= @FileSignedDownload
				,FileZipped				= @FileZipped
				,ManualClose			= isnull(@ManualClose,0)
				,SendMail				= isnull(@SendMail	 ,0)
				,[State]				= @State
		 WHERE ID = @Id
		
		select @NewJSON = a.JSON from [FirmaDigital].[TblDocumentos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.id = @id

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[FirmaDigital].[TblDocumentos]','[FirmaDigital].[spIUDocumentos]','UPDATE',@NewJSON,@OldJSON
	END

	EXEC [FirmaDigital].[spBuscarDocumentos] @ID = @ID
END
GO
