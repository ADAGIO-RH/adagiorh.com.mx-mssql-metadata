USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Reclutamiento].[spIUFamiliarCandidato](
							@IDFamiliarCandidato int = 0
						   ,@IDCandidato int
						   ,@IDParentesco int
						   ,@NombreFamiliar varchar(50)
						   ,@FechaNacimientoFamiliar date
						   ,@Vivo bit
						   ,@IDUsuario int = 0 )
AS   
BEGIN  

    DECLARE @OldJSON Varchar(Max),
	    @NewJSON Varchar(Max),
        @IDUsuarioAdmin int ,
        @Message varchar(max);

    select @IDUsuarioAdmin=cast(Valor as int)  from App.tblConfiguracionesGenerales where IDConfiguracion='IDUsuarioAdmin'

    IF(@IDFamiliarCandidato = 0)  
    BEGIN  
        INSERT INTO [Reclutamiento].[tblFamiliaresCandidato]
           ([IDCandidato]
           ,[IDParentesco]
           ,[NombreFamiliar]
           ,[FechaNacimientoFamiliar]
           ,[Vivo])
        VALUES
           (
           @IDCandidato
           ,@IDParentesco
           ,upper(@NombreFamiliar)
           ,@FechaNacimientoFamiliar
           ,@Vivo)

		SET @IDFamiliarCandidato = @@IDENTITY  

        if(@IDUsuario = 0)
		BEGIN
            SET @IDUsuario=@IDUsuarioAdmin;
            SET @Message = '{"IDCandidato":'+cast(@IDCandidato as varchar(5))+', "Carrers": 1 }';            
        END		

        select @NewJSON = a.JSON from [Reclutamiento].[tblFamiliaresCandidato] b
        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
        WHERE b.IDFamiliarCandidato = @IDFamiliarCandidato

        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblFamiliaresCandidato]','[Reclutamiento].[spIUFamiliarCandidato]','INSERT',@NewJSON,'',@Message		

    END  
    ELSE  
    BEGIN  
        select @OldJSON = a.JSON from [Reclutamiento].[tblFamiliaresCandidato] b
            Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
            WHERE b.IDFamiliarCandidato = @IDFamiliarCandidato


        UPDATE [Reclutamiento].[tblFamiliaresCandidato]
        SET [IDCandidato] = @IDCandidato
            ,[IDParentesco] = @IDParentesco
            ,[NombreFamiliar] = @NombreFamiliar
            ,[FechaNacimientoFamiliar] = @FechaNacimientoFamiliar
            ,[Vivo] = @Vivo
        WHERE [IDFamiliarCandidato] = @IDFamiliarCandidato


        if(@IDUsuario = 0)
		BEGIN
            SET @IDUsuario=@IDUsuarioAdmin;
            SET @Message = '{"IDCandidato":'+cast(@IDCandidato as varchar(5))+', "Carrers": 1 }';
        END

        select @NewJSON = a.JSON from [Reclutamiento].[tblFamiliaresCandidato] b
            Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
            WHERE b.IDFamiliarCandidato = @IDFamiliarCandidato

        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblFamiliaresCandidato]','[Reclutamiento].[spIUFamiliarCandidato]','UPDATE',@NewJSON,@OldJSON,@Message
    END  

	Exec [Reclutamiento].[spBuscarFamiliarCandidato] @IDFamiliarCandidato = @IDFamiliarCandidato, @IDCandidato=@IDCandidato
END
GO
