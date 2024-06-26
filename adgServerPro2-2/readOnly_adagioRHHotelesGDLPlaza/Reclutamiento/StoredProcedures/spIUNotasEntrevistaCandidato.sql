USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reclutamiento].[spIUNotasEntrevistaCandidato](
						@IDNotasEntrevistaCandidato int = 0
						,@IDCandidato int	
						,@Nota varchar(max)
						,@IDUsuario int
						)
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)


 IF(@IDNotasEntrevistaCandidato = 0)  
 BEGIN  


	INSERT INTO [Reclutamiento].[tblNotasEntrevistaCandidato]
           ([IDCandidato]
           ,[Nota]
		   ,[FechaHora]
           ,[IDUsuario])
     VALUES
           (@IDCandidato
           ,upper(@Nota)
		   ,getdate()
           ,@IDUsuario)


	
		SET @IDNotasEntrevistaCandidato = @@IDENTITY  

	  	select @NewJSON = a.JSON from [Reclutamiento].[tblNotasEntrevistaCandidato] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNotasEntrevistaCandidato = @IDNotasEntrevistaCandidato

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblNotasEntrevistaCandidato]','[Reclutamiento].[spIUNotasEntrevistaCandidato]','INSERT',@NewJSON,''

 END  
 ELSE  
 BEGIN  
	  	select @OldJSON = a.JSON from [Reclutamiento].[tblNotasEntrevistaCandidato] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNotasEntrevistaCandidato = @IDNotasEntrevistaCandidato


		UPDATE [Reclutamiento].[tblNotasEntrevistaCandidato]
		   SET [IDCandidato] = @IDCandidato
			  ,[Nota] = upper(@Nota)
			  ,[FechaHora] = getdate()
			  ,[IDUsuario] = @IDUsuario
		 WHERE IDNotasEntrevistaCandidato = @IDNotasEntrevistaCandidato
		 
           
		select @NewJSON = a.JSON from [Reclutamiento].[tblNotasEntrevistaCandidato] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNotasEntrevistaCandidato = @IDNotasEntrevistaCandidato
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblNotasEntrevistaCandidato]','[Reclutamiento].[spIUNotasEntrevistaCandidato]','UPDATE',@NewJSON,@OldJSON

 END  

	Exec [Reclutamiento].[spBuscarNotasEntrevistaCandidato] @IDNotasEntrevistaCandidato = @IDNotasEntrevistaCandidato
	
	END
GO
