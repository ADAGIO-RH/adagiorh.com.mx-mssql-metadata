USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reclutamiento].[spIUNotasEntrevistaCandidatoPlaza](
		@IDNotasEntrevistaCandidatoPlaza int = 0
		,@IDCandidatoPlaza int	
		,@IDCandidato int	
		,@Nota varchar(max)
		,@IDUsuario int
		)
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)


 IF(@IDNotasEntrevistaCandidatoPlaza = 0)  
 BEGIN  


	INSERT INTO [Reclutamiento].[tblNotasEntrevistaCandidatoPlaza]
           ([IDCandidatoPlaza]
		   ,[IDCandidato]
           ,[Nota]
		   ,[FechaHora]
           ,[IDUsuario])
     VALUES
           (CASE WHEN isnull(@IDCandidatoPlaza,0) = 0 THEN null else @IDCandidatoPlaza end
		   ,@IDCandidato
           ,@Nota
		   ,getdate()
           ,@IDUsuario)


	
		SET @IDNotasEntrevistaCandidatoPlaza = @@IDENTITY  

	  	select @NewJSON = a.JSON from [Reclutamiento].[tblNotasEntrevistaCandidatoPlaza] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNotasEntrevistaCandidatoPlaza = @IDNotasEntrevistaCandidatoPlaza

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblNotasEntrevistaCandidatoPlaza]','[Reclutamiento].[spIUNotasEntrevistaCandidatoPlaza]','INSERT',@NewJSON,''

 END  
 ELSE  
 BEGIN  
	  	select @OldJSON = a.JSON from [Reclutamiento].[tblNotasEntrevistaCandidatoPlaza] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDNotasEntrevistaCandidatoPlaza = @IDNotasEntrevistaCandidatoPlaza


		UPDATE [Reclutamiento].[tblNotasEntrevistaCandidatoPlaza]
		   SET [IDCandidatoPlaza] = CASE WHEN isnull(@IDCandidatoPlaza,0) = 0 THEN null else @IDCandidatoPlaza end 
			  ,[IDCandidato] = @IDCandidato
			  ,[Nota] = @Nota
			  ,[FechaHora] = getdate()
			  ,[IDUsuario] = @IDUsuario
		 WHERE IDNotasEntrevistaCandidatoPlaza = @IDNotasEntrevistaCandidatoPlaza
		 
           
		select @NewJSON = a.JSON from [Reclutamiento].[tblNotasEntrevistaCandidatoPlaza] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNotasEntrevistaCandidatoPlaza = @IDNotasEntrevistaCandidatoPlaza
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblNotasEntrevistaCandidatoPlaza]','[Reclutamiento].[spIUNotasEntrevistaCandidatoPlaza]','UPDATE',@NewJSON,@OldJSON

 END  

	Exec [Reclutamiento].[spBuscarNotasEntrevistaCandidatoPlaza] @IDNotasEntrevistaCandidatoPlaza = @IDNotasEntrevistaCandidatoPlaza
	
END
GO
