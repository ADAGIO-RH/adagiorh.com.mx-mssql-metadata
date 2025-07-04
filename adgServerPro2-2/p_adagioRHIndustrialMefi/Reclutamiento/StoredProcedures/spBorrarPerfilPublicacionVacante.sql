USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spBorrarPerfilPublicacionVacante](
	 @IDPerfilPublicacionVacante	int = 0
	,@IDUsuario		int 
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [Reclutamiento].[tblPerfilPublicacionVacante] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPerfilPublicacionVacante = @IDPerfilPublicacionVacante

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblPerfilPublicacionVacante]','[Reclutamiento].[spBorrarPerfilPublicacionVacante]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  
		  DELETE [Reclutamiento].[tblPerfilPublicacionVacante]
			WHERE IDPerfilPublicacionVacante = @IDPerfilPublicacionVacante
				
		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
