USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reclutamiento].[spIUDocumentoTrabajoCandidato](
								@IDDocumentoTrabajoCandidato int = 0
							   ,@IDDocumentoTrabajo int
							   ,@IDCandidato int
							   ,@Validacion varchar(50) = null
    						   ,@IDUsuario int = 0 
						    )
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)


 IF(@IDDocumentoTrabajoCandidato  = 0)  
 BEGIN  

INSERT INTO [Reclutamiento].[tblDocumentosTrabajoCandidato]
           ([IDDocumentoTrabajo]
           ,[IDCandidato]
           ,[Validacion])
     VALUES
           (@IDDocumentoTrabajo
           ,@IDCandidato 
           ,@Validacion)


		SET @IDDocumentoTrabajoCandidato = @@IDENTITY  

	  	select @NewJSON = a.JSON from [Reclutamiento].[tblDocumentosTrabajoCandidato] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumentoTrabajoCandidato = @IDDocumentoTrabajoCandidato 

		if(@IDUsuario <> 0)
		BEGIN
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblDocumentosTrabajoCandidato]','[Reclutamiento].[spIUDocumentoTrabajoCandidato]','INSERT',@NewJSON,''
		END

 END  
 ELSE  
 BEGIN  
	  	select @OldJSON = a.JSON from [Reclutamiento].[tblDocumentosTrabajoCandidato] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumentoTrabajoCandidato = @IDDocumentoTrabajoCandidato 


		UPDATE [Reclutamiento].[tblDocumentosTrabajoCandidato]
		   SET [IDDocumentoTrabajo] = @IDDocumentoTrabajo
			  ,[IDCandidato] = @IDCandidato
			  ,[Validacion] = @Validacion
		 WHERE [IDDocumentoTrabajoCandidato] = @IDDocumentoTrabajoCandidato

		select @NewJSON = a.JSON from [Reclutamiento].[tblDocumentosTrabajoCandidato] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumentoTrabajoCandidato = @IDDocumentoTrabajoCandidato 
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblDocumentosTrabajoCandidato]','[Reclutamiento].[spIUDocumentoTrabajoCandidato]','UPDATE',@NewJSON,@OldJSON

 END  

	Exec [Reclutamiento].[spBuscarDocumentosTrabajoCandidato] @IDDocumentoTrabajoCandidato  = @IDDocumentoTrabajoCandidato 
END
GO
