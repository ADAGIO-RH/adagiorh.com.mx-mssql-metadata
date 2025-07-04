USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spIUClienteHonorarios(
	@IDClienteHonorario int = 0,
	@IDCliente int,
	@Porcentaje Decimal(18,4),
	@IncluyeIVA bit = 1,
	@IDUsuario int
)
AS
BEGIN
	Declare @msj nvarchar(max) ;    
    
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF(ISNULL(@IDCliente,'') = '')    
    BEGIN    
		RETURN;    
    END  


	IF(@IDClienteHonorario = 0 or @IDClienteHonorario is null)    
    BEGIN      
		BEGIN TRY
			INSERT INTO Procom.TblClienteHonorarios(IDCliente,Porcentaje,IncluyeIVA)    
			VALUES(
				 @IDCliente
				,isnull(@Porcentaje,0.00)
				,ISNULL(@IncluyeIVA,0)
			) 
		
			set @IDClienteHonorario = @@IDENTITY

			select @NewJSON = a.JSON from [Procom].[TblClienteHonorarios] b
				inner join RH.tblCatClientes c on C.IDCliente = b.IDCliente
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.*,c.NombreComercial For XML Raw)) ) a
			WHERE b.IDClienteHonorario = @IDClienteHonorario
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblClienteHonorarios]','[Procom].[spIUClienteHonorarios]','INSERT',@NewJSON,''	
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;

			SELECT
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

			-- Use RAISERROR inside the CATCH block to return error
			-- information about the original error that caused
			-- execution to jump to the CATCH block.
			RAISERROR (@ErrorMessage, -- Message text.
					   @ErrorSeverity, -- Severity.
					   @ErrorState -- State.
					   );
		END CATCH
	END
	ELSE
	BEGIN 
		select @OldJSON =  a.JSON from [Procom].[TblClienteHonorarios] b
				inner join RH.tblCatClientes c on C.IDCliente = b.IDCliente
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.*,c.NombreComercial For XML Raw)) ) a
			WHERE b.IDClienteHonorario = @IDClienteHonorario
	 
		UPDATE [Procom].[TblClienteHonorarios]    
		SET 
		  Porcentaje			= ISNULL(@Porcentaje,0.00)
		  ,IncluyeIVA			= isnull(0,0)
		WHERE IDCliente = @IDCliente   
		and IDClienteHonorario = @IDClienteHonorario
		
		select @NewJSON = a.JSON from [Procom].[TblClienteHonorarios] b
				inner join RH.tblCatClientes c on C.IDCliente = b.IDCliente
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.*,c.NombreComercial For XML Raw)) ) a
			WHERE b.IDClienteHonorario = @IDClienteHonorario
	 
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblClienteHonorarios]','[Procom].[spIUClienteHonorarios]','UPDATE',@NewJSON,@OldJSON
	END

END
GO
