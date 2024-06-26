USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spIUMiembrosComisionMixta](
	 @IDMiembroComisionMixta int = 0
	,@IDClienteComisionMixta int
	,@IDCatTipoMiembroComisionMixta int
	,@NombreCompleto Varchar(255)
	,@Puesto Varchar(MAX)
	,@FechaIngreso Date = getdate
	,@IMSS Varchar(50)
	,@FechaIMSS Date 
	,@IDUsuario int	
)
AS
BEGIN
	 Declare @msj nvarchar(max) ;    
    
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF(ISNULL(@IDClienteComisionMixta,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@IDCatTipoMiembroComisionMixta,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@IDCatTipoMiembroComisionMixta,0) = 0)    
    BEGIN    
		RETURN;    
    END 


	IF(@IDMiembroComisionMixta = 0 or @IDMiembroComisionMixta is null)    
    BEGIN        
    
		INSERT INTO Procom.[tblMiembrosComisionMixta](
			 IDClienteComisionMixta
			,IDCatTipoMiembroComisionMixta
			,NombreCompleto 
			,Puesto 
			,FechaIngreso 
			,IMSS
			,FechaIMSS
		)    
		VALUES(
		 @IDClienteComisionMixta
		,@IDCatTipoMiembroComisionMixta
		,UPPER(@NombreCompleto) 
		,UPPER(@Puesto) 
		,isnull(@FechaIngreso,getdate())
		,UPPER(@IMSS)
		,isnull(@FechaIMSS,'9999-12-31')
		) 
		
		set @IDMiembroComisionMixta = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblMiembrosComisionMixta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMiembroComisionMixta = @IDMiembroComisionMixta
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblMiembrosComisionMixta]','[Procom].[spIUMiembrosComisionMixta]','INSERT',@NewJSON,''	

		   
    END    
    ELSE    
    BEGIN   
	
		select @OldJSON = a.JSON from [Procom].[tblMiembrosComisionMixta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMiembroComisionMixta = @IDMiembroComisionMixta
	 
		UPDATE [Procom].[tblMiembrosComisionMixta]    
		SET 
			 IDCatTipoMiembroComisionMixta = @IDCatTipoMiembroComisionMixta
			,NombreCompleto = UPPER(@NombreCompleto)
			,Puesto = UPPER(@Puesto)
			,IMSS = UPPER(@IMSS)
			,FechaIngreso = isnull(@FechaIngreso,getdate())
			,FechaIMSS = isnull(@FechaIMSS,'9999-12-31')
		WHERE IDClienteComisionMixta = @IDClienteComisionMixta   
		and IDMiembroComisionMixta = @IDMiembroComisionMixta
		
		select @NewJSON = a.JSON from [Procom].[tblMiembrosComisionMixta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMiembroComisionMixta = @IDMiembroComisionMixta
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblMiembrosComisionMixta]','[Procom].[spIUMiembrosComisionMixta]','UPDATE',@NewJSON,@OldJSON
		    
    END;    

END;
GO
