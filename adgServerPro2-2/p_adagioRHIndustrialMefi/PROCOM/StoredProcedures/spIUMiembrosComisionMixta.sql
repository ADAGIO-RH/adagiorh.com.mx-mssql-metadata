USE [p_adagioRHIndustrialMefi]
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
	,@Puesto Varchar(MAX)= null
	,@FechaIngreso Date = null
	,@IMSS Varchar(50) = null
	,@FechaIMSS Date  = null
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
		,@FechaIngreso
		,UPPER(@IMSS)
		,@FechaIMSS
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
			,FechaIngreso = @FechaIngreso
			,FechaIMSS = @FechaIMSS
		WHERE IDClienteComisionMixta = @IDClienteComisionMixta   
		and IDMiembroComisionMixta = @IDMiembroComisionMixta
		
		select @NewJSON = a.JSON from [Procom].[tblMiembrosComisionMixta] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMiembroComisionMixta = @IDMiembroComisionMixta
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblMiembrosComisionMixta]','[Procom].[spIUMiembrosComisionMixta]','UPDATE',@NewJSON,@OldJSON
		    
    END;    

END;
GO
