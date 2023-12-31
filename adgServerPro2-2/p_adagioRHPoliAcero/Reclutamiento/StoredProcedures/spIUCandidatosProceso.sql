USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reclutamiento].[spIUCandidatosProceso](
							 @IDCandidato int
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

	  	select @OldJSON = a.JSON from [Reclutamiento].[tblCandidatosProceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDCandidato] = @IDCandidato 

		UPDATE [Reclutamiento].[tblCandidatosProceso]
		   SET [IDCandidato] = @IDCandidato
			  ,[IDPuestoPreasignado] = @IDPuestoPreasignado
			  ,[SueldoPreasignado] = @SueldoPreasignado
			  ,[IDEstatusProceso] = @IDEstatusProceso
		 WHERE [IDCandidato] = @IDCandidato 



		select @NewJSON = a.JSON from [Reclutamiento].[tblCandidatosProceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDCandidato] = @IDCandidato
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatosProceso]','[Reclutamiento].[spIUCandidatosProceso]','UPDATE',@NewJSON,@OldJSON
 
END
GO
