USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reclutamiento].[spIUDocumentosTrabajo](
						@IDDocumentoTrabajo int = 0
						,@Descripcion varchar(50)
						,@IDUsuario int = 0 
						)
AS  
BEGIN  

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)


 IF(@IDDocumentoTrabajo = 0)  
 BEGIN  

	  INSERT INTO [Reclutamiento].[tblCatDocumentosTrabajo]
           ([Descripcion])
     VALUES
           (
           @Descripcion)

		SET @IDDocumentoTrabajo = @@IDENTITY  

	  	select @NewJSON = a.JSON from [Reclutamiento].[tblCatDocumentosTrabajo] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumentoTrabajo = @IDDocumentoTrabajo

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCatDocumentosTrabajo]','[Reclutamiento].[spIUDocumentosTrabajo]','INSERT',@NewJSON,''

 END  
 ELSE  
 BEGIN  
	  	select @OldJSON = a.JSON from [Reclutamiento].[tblCatDocumentosTrabajo] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumentoTrabajo = @IDDocumentoTrabajo

		UPDATE [Reclutamiento].[tblCatDocumentosTrabajo]
		SET 
		  [Descripcion] = @Descripcion
		   WHERE IDDocumentoTrabajo = @IDDocumentoTrabajo

		select @NewJSON = a.JSON from [Reclutamiento].[tblCatDocumentosTrabajo] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDocumentoTrabajo = @IDDocumentoTrabajo
			   
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCatDocumentosTrabajo]','[Reclutamiento].[spIUDocumentosTrabajo]','UPDATE',@NewJSON,''

 END  

	Exec [Reclutamiento].[spBuscarDocumentosTrabajo] @IDDocumentoTrabajo = @IDDocumentoTrabajo
END
GO
