USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spIUClienteHonorariosComisionistas(
	@IDClienteHonorarioComisionista int = 0,
	@IDClienteHonorario int,
	@IDCatComisionista int,
	@Porcentaje Decimal(18,4),
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	


	IF(@IDClienteHonorarioComisionista = 0 or @IDClienteHonorarioComisionista is null)    
    BEGIN      
		BEGIN TRY
			INSERT INTO Procom.TblClienteHonorariosComisionistas(IDClienteHonorario,IDCatComisionista,Porcentaje)    
			VALUES(
				 @IDClienteHonorario
				,@IDCatComisionista
				,ISNULL(@Porcentaje,0)
			) 
		
			set @IDClienteHonorarioComisionista = @@IDENTITY

			select @NewJSON = a.JSON from [Procom].[TblClienteHonorariosComisionistas] b
				inner join Procom.TblClienteHonorarios H on H.IDClienteHonorario = b.IDClienteHonorario
				inner join RH.tblCatClientes c on C.IDCliente = H.IDCliente
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.*,c.NombreComercial For XML Raw)) ) a
			WHERE b.IDClienteHonorarioComisionista = @IDClienteHonorarioComisionista
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblClienteHonorariosComisionistas]','[Procom].[spIUClienteHonorariosComisionistas]','INSERT',@NewJSON,''	
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
		select @OldJSON =  a.JSON from [Procom].[TblClienteHonorariosComisionistas] b
				inner join Procom.TblClienteHonorarios H on H.IDClienteHonorario = b.IDClienteHonorario
				inner join RH.tblCatClientes c on C.IDCliente = H.IDCliente
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.*,c.NombreComercial For XML Raw)) ) a
			WHERE b.IDClienteHonorarioComisionista = @IDClienteHonorarioComisionista
	 
		UPDATE [Procom].[TblClienteHonorariosComisionistas]    
		SET 
		  Porcentaje			= ISNULL(@Porcentaje,0.00)
		  ,IDCatComisionista			= @IDCatComisionista
		WHERE  IDClienteHonorario = @IDClienteHonorario
		and IDClienteHonorarioComisionista = @IDClienteHonorarioComisionista

		select @NewJSON = a.JSON from [Procom].[TblClienteHonorariosComisionistas] b
				inner join Procom.TblClienteHonorarios H on H.IDClienteHonorario = b.IDClienteHonorario
				inner join RH.tblCatClientes c on C.IDCliente = H.IDCliente
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.*,c.NombreComercial For XML Raw)) ) a
			WHERE b.IDClienteHonorarioComisionista = @IDClienteHonorarioComisionista
	 
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblClienteHonorariosComisionistas]','[Procom].[spIUClienteHonorariosComisionistas]','UPDATE',@NewJSON,@OldJSON
	END

END
GO
