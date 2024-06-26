USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reclutamiento].[spIUCandidatosProceso](
							 @IDCandidatoProceso int = 0
							,@IDCandidato int
							,@VacanteDeseada varchar(50) = NULL
							,@SueldoDeseado varchar(50) = NULL
							,@IDPuestoPreasignado int = 0
							,@SueldoPreasignado varchar(50) = NULL
							,@IDEstatusProceso int = 1
							,@IDUsuario int = 0 
						)
AS  
BEGIN  


DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)


 IF(@IDCandidatoProceso  = 0 AND NOT EXISTS (SELECT * FROM [Reclutamiento].[tblCandidatosProceso] WHERE [IDCandidato] = @IDCandidato) )  
 BEGIN  

	INSERT INTO [Reclutamiento].[tblCandidatosProceso]
           ([IDCandidato]
           ,[VacanteDeseada]
           ,[SueldoDeseado]
           ,[IDPuestoPreasignado]
           ,[SueldoPreasignado]
           ,[IDEstatusProceso])
		 VALUES
			   (@IDCandidato
			   ,@VacanteDeseada
			   ,@SueldoDeseado
			   ,@IDPuestoPreasignado
			   ,@SueldoPreasignado 
			   ,@IDEstatusProceso)


		SET @IDCandidatoProceso = @@IDENTITY  

	  	select @NewJSON = a.JSON from [Reclutamiento].[tblCandidatosProceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidatoProceso = @IDCandidatoProceso 

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatosProceso]','[Reclutamiento].[spIUCandidatosProceso]','INSERT',@NewJSON,''


 END  
 ELSE  
 BEGIN  
	  	select @OldJSON = a.JSON from [Reclutamiento].[tblCandidatosProceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidatoProceso = @IDCandidatoProceso 

		UPDATE [Reclutamiento].[tblCandidatosProceso]
		   SET [IDCandidato] = @IDCandidato
			  ,[IDPuestoPreasignado] = @IDPuestoPreasignado
			  ,[SueldoPreasignado] = @SueldoPreasignado
			  ,[IDEstatusProceso] = @IDEstatusProceso
		 WHERE [IDCandidato] = @IDCandidato 



		select @NewJSON = a.JSON from [Reclutamiento].[tblCandidatosProceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidatoProceso = @IDCandidatoProceso
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatosProceso]','[Reclutamiento].[spIUCandidatosProceso]','UPDATE',@NewJSON,@OldJSON

 END  
		EXEC [Reclutamiento].[spBuscarCandidatosProceso] @IDCandidatoProceso = @IDCandidatoProceso 
END
GO
