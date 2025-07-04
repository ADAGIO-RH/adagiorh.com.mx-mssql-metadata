USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spIUClienteCuotaAfiliacion](
	 @IDClienteCuotaAfiliacion int = 0
	,@IDCliente int = 0
	,@Anio int
	,@Cuota Decimal(18,2)
	,@Descripcion Varchar(100)
	,@FechaVigencia DATE
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

	IF(ISNULL(@Anio,0) = 0)    
    BEGIN    
		RETURN;    
    END  

	IF(ISNULL(@Cuota,'') = 0.00)    
    BEGIN    
		RETURN;    
    END 

	set @Descripcion = UPPER (@Descripcion)

	IF(@IDClienteCuotaAfiliacion = 0 or @IDClienteCuotaAfiliacion is null)    
    BEGIN      
    
		INSERT INTO Procom.tblClienteCuotaAfiliacion(
			 IDCliente
			,Anio
			,Cuota
			,Descripcion
			,FechaVigencia
		)    
		VALUES(
		@IDCliente
		,@Anio
		,isnull(@Cuota,0.00)
		,@Descripcion
		,@FechaVigencia
		) 
		
		set @IDClienteCuotaAfiliacion = @@IDENTITY

		select @NewJSON = a.JSON from [Procom].[tblClienteCuotaAfiliacion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteCuotaAfiliacion = @IDClienteCuotaAfiliacion
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteCuotaAfiliacion]','[Procom].[spBuscarClienteCuotaAfiliacion]','INSERT',@NewJSON,''	

		DECLARE @IDCatEstatusCuotaAfiliacion int
		SELECT TOP 1 @IDCatEstatusCuotaAfiliacion = IDCatEstatusCuotaAfiliacion from Procom.tblCatEstatusCuotaAfiliacion where Descripcion = 'Pendiente'
		
		EXEC PROCOM.spIUClienteCuotaAfiliacionEstatus
		   @IDClienteCuotaAfiliacion = @IDClienteCuotaAfiliacion
			,@IDCatEstatusCuotaAfiliacion = @IDCatEstatusCuotaAfiliacion
			,@IDUsuario = @IDUsuario
    END    
    ELSE    
    BEGIN   
	
		select @OldJSON = a.JSON from [Procom].[tblClienteCuotaAfiliacion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteCuotaAfiliacion = @IDClienteCuotaAfiliacion
	 
		UPDATE [Procom].[tblClienteCuotaAfiliacion]    
		SET 
		 Anio = @Anio
		,Cuota = isnull(@Cuota,0.00)
		,Descripcion = @Descripcion
		,FechaVigencia = @FechaVigencia
		WHERE IDCliente = @IDCliente   
		and IDClienteCuotaAfiliacion = @IDClienteCuotaAfiliacion
		
		select @NewJSON = a.JSON from [Procom].[tblClienteCuotaAfiliacion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClienteCuotaAfiliacion = @IDClienteCuotaAfiliacion
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteCuotaAfiliacion]','[Procom].[spBuscarClienteCuotaAfiliacion]','UPDATE',@NewJSON,@OldJSON
		    
    END;    
END;
GO
