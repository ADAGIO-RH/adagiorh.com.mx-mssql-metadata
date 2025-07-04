USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spIUClienteEstatus(
	@IDClienteEstatus int = 0,
	@IDCliente int,
	@IDCatEstatusCliente int,
	@IDUsuario int
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

	IF(ISNULL(@IDCatEstatusCliente,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(@IDClienteEstatus = 0 or @IDClienteEstatus is null)    
    BEGIN      
    
		INSERT INTO Procom.tblClienteEstatus(
			 IDCliente
			,IDCatEstatusCliente
		)    
		VALUES(
		@IDCliente
		,@IDCatEstatusCliente
		) 
		
		set @IDClienteEstatus = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblClienteEstatus] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteEstatus = @IDClienteEstatus
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteEstatus]','[Procom].[spIUClienteEstatus]','INSERT',@NewJSON,''	

    END    
    ELSE    
    BEGIN   
	
		select @OldJSON = a.JSON from [Procom].[tblClienteEstatus] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteEstatus = @IDClienteEstatus
	 
		UPDATE [Procom].[tblClienteEstatus]    
		SET 
		 IDCatEstatusCliente = @IDCatEstatusCliente
	
		WHERE IDCliente = @IDCliente   
		and IDClienteEstatus = @IDClienteEstatus
		
		select @NewJSON = a.JSON from [Procom].[tblClienteEstatus] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteEstatus = @IDClienteEstatus
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteEstatus]','[Procom].[spIUClienteEstatus]','UPDATE',@NewJSON,@OldJSON    
    END;    
END
GO
