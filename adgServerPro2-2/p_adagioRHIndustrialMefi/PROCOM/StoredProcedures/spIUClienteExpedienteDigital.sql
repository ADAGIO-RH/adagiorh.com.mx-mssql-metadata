USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spIUClienteExpedienteDigital](
	@IDClienteExpedienteDigital int = 0,
	@IDCliente int,
	@Nombre Varchar(500),
	@Name Varchar(500) = null,
	@ContentType Varchar(500) = null,
	@PathFile Varchar(max) = null,
	@Size int = null,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF(ISNULL(@Nombre,'') = '')    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@IDCliente,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(@IDClienteExpedienteDigital = 0 or @IDClienteExpedienteDigital is null)    
    BEGIN        
    
		INSERT INTO Procom.[tblClienteExpedienteDigital](
			IDCliente
			,Nombre
			,Name
			,ContentType
			,PathFile
			,Size
		)    
		VALUES(
		     @IDCliente
			,upper(@Nombre)
			,@Name
			,@ContentType
			,@PathFile
			,@Size
		) 
		
		set @IDClienteExpedienteDigital = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblClienteExpedienteDigital] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteExpedienteDigital = @IDClienteExpedienteDigital
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteExpedienteDigital]','[Procom].[spIUClienteExpedienteDigital]','INSERT',@NewJSON,''	

		   
    END    
    ELSE    
    BEGIN   
	
		select @OldJSON = a.JSON from [Procom].[tblClienteExpedienteDigital] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteExpedienteDigital = @IDClienteExpedienteDigital
	 
		UPDATE [Procom].[tblClienteExpedienteDigital]    
		SET 
			 Nombre			= upper(@Nombre)		
			,Name			= @Name
			,ContentType	= @ContentType
			,PathFile		= @PathFile	
			,Size			= @Size		
		WHERE IDCliente = @IDCliente   
		and IDClienteExpedienteDigital = @IDClienteExpedienteDigital
		
		select @NewJSON = a.JSON from [Procom].[tblClienteExpedienteDigital] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteExpedienteDigital = @IDClienteExpedienteDigital
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteExpedienteDigital]','[Procom].[spIUClienteExpedienteDigital]','UPDATE',@NewJSON,@OldJSON
		    
    END;    


END
GO
