USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reclutamiento].[spCambiarIDEstatusProcesoCandidato](
		 @IDCandidato int =0 
		,@IDEstatusProceso int
		,@IDUsuario int = 0 
	)
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)



UPDATE [Reclutamiento].[tblCandidatosProceso]
   SET [IDEstatusProceso] = @IDEstatusProceso
 WHERE [IDCandidato] = @IDCandidato

	 select 
	 @OldJSON = a.JSON from [Reclutamiento].[tblCandidatosProceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCandidato = @IDCandidato 

		select @NewJSON = a.JSON from [Reclutamiento].[tblCandidatosProceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDCandidato] = @IDCandidato
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatosProceso]','[Reclutamiento].[spCambiarIDEstatusProcesoCandidato]','UPDATE',@NewJSON,@OldJSON

	--Exec [Reclutamiento].[spBuscarCandidatos] @IDCandidato = @IDCandidato
END
GO
