USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE PROCOM.spIUClienteContacto(
	 @IDClienteContacto int = 0
	,@IDCliente int = 0
	,@IDCatTipoContacto int = 0
	,@Valor Varchar(max)
	,@IDUsuario int	
)
AS
BEGIN
	 Declare @msj nvarchar(max) ;    
    
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF(ISNULL(@IDCliente,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@IDCatTipoContacto,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@Valor,'') = '')    
    BEGIN    
		RETURN;    
    END 


	IF(@IDClienteContacto = 0 or @IDClienteContacto is null)    
    BEGIN        
    
		INSERT INTO Procom.tblClienteContacto(
			 IDCliente
			,IDCatTipoContacto
			,Valor
		)    
		VALUES(
		 @IDCliente
		,@IDCatTipoContacto
		,LOWER(@Valor)
		) 
		
		set @IDClienteContacto = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblClienteContacto] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteContacto = @IDClienteContacto
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteContacto]','[Procom].[spIUClienteContacto]','INSERT',@NewJSON,''	

		   
    END    
    ELSE    
    BEGIN   
	
		select @OldJSON = a.JSON from [Procom].[tblClienteContacto] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteContacto = @IDClienteContacto
	 
		UPDATE [Procom].[tblClienteContacto]    
		SET 
		 IDCatTipoContacto = @IDCatTipoContacto
		 ,Valor = Lower(@Valor)
		
		WHERE IDCliente = @IDCliente   
		and IDClienteContacto = @IDClienteContacto
		
		select @NewJSON = a.JSON from [Procom].[tblClienteContacto] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteContacto = @IDClienteContacto
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteContacto]','[Procom].[spIUClienteContacto]','UPDATE',@NewJSON,@OldJSON
		    
    END;    

END;
GO
