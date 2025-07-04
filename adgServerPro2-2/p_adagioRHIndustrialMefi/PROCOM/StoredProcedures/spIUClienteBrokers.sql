USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spIUClienteBrokers(
	@IDClienteBroker int = 0,
	@IDCliente int,
	@IDCatBroker int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	


	IF(@IDClienteBroker = 0 or @IDClienteBroker is null)    
    BEGIN      
		BEGIN TRY
			INSERT INTO Procom.tblClienteBrokers(IDCliente,IDCatBroker)    
			VALUES(@IDCliente,@IDCatBroker) 
		
			set @IDClienteBroker = @@IDENTITY

			select @NewJSON = a.JSON from [Procom].[tblClienteBrokers] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDClienteBroker = @IDClienteBroker
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteBrokers]','[Procom].[spIUClienteBrokers]','INSERT',@NewJSON,''	

		END TRY
		BEGIN CATCH
			

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

		BEGIN TRY
			select @OldJSON =  a.JSON from [Procom].[tblClienteBrokers] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDClienteBroker = @IDClienteBroker

			UPDATE [Procom].[tblClienteBrokers]    
			SET 
			  IDCatBroker			=IDCatBroker
			WHERE  IDClienteBroker = @IDClienteBroker
			and IDCliente = @IDCliente

			select @NewJSON =  a.JSON from [Procom].[tblClienteBrokers] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDClienteBroker = @IDClienteBroker
	 
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteBrokers]','[Procom].[spIUClienteBrokers]','UPDATE',@NewJSON,@OldJSON
		END TRY
		BEGIN CATCH
		
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
END
GO
