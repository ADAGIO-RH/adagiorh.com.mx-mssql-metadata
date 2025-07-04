USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE PROCOM.spIUClienteCuotaAfiliacionEstatus(
	 @IDClienteCuotaAfiliacionEstatus int = 0
	,@IDClienteCuotaAfiliacion int
	,@IDCatEstatusCuotaAfiliacion int
	,@IDUsuario int	
)
AS
BEGIN
	 Declare @msj nvarchar(max) ;    
    
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF(ISNULL(@IDClienteCuotaAfiliacion,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@IDCatEstatusCuotaAfiliacion,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(@IDClienteCuotaAfiliacionEstatus = 0 or @IDClienteCuotaAfiliacionEstatus is null)    
    BEGIN      
    
		INSERT INTO Procom.tblClienteCuotaAfiliacionEstatus(
			IDClienteCuotaAfiliacion
			,IDCatEstatusCuotaAfiliacion
			,FechaHora
		)    
		VALUES(
			@IDClienteCuotaAfiliacion
			,@IDCatEstatusCuotaAfiliacion
			,GETDATE()
		) 
		
		set @IDClienteCuotaAfiliacionEstatus = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblClienteCuotaAfiliacionEstatus] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteCuotaAfiliacionEstatus = @IDClienteCuotaAfiliacionEstatus
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteCuotaAfiliacionEstatus]','[Procom].[spIUClienteCuotaAfiliacionEstatus]','INSERT',@NewJSON,''	

		   
    END    
    ELSE    
    BEGIN   
	
		select @OldJSON = a.JSON from [Procom].[tblClienteCuotaAfiliacionEstatus] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteCuotaAfiliacionEstatus = @IDClienteCuotaAfiliacionEstatus
	 
		UPDATE [Procom].[tblClienteCuotaAfiliacionEstatus]    
		SET 
		 IDCatEstatusCuotaAfiliacion = @IDCatEstatusCuotaAfiliacion
		,FechaHora = GETDATE()
		WHERE IDClienteCuotaAfiliacion = @IDClienteCuotaAfiliacion 
		and IDClienteCuotaAfiliacionEstatus = @IDClienteCuotaAfiliacionEstatus
		
		select @NewJSON = a.JSON from [Procom].[tblClienteCuotaAfiliacionEstatus] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteCuotaAfiliacionEstatus = @IDClienteCuotaAfiliacionEstatus
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteCuotaAfiliacionEstatus]','[Procom].[spIUClienteCuotaAfiliacionEstatus]','UPDATE',@NewJSON,@OldJSON
		    
    END;    
END;
GO
