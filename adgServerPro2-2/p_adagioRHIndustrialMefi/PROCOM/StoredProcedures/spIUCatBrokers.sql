USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spIUCatBrokers(
	@IDCatBroker int = 0,
	@Codigo Varchar(20),
	@Nombre Varchar(255),
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	


	IF(@IDCatBroker = 0 or @IDCatBroker is null)    
    BEGIN      
		BEGIN TRY
			INSERT INTO Procom.TblCatBrokers(Codigo,Nombre)    
			VALUES(UPPER(@Codigo),UPPER(@Nombre)) 
		
			set @IDCatBroker = @@IDENTITY

			select @NewJSON = a.JSON from [Procom].[TblCatBrokers] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDCatBroker = @IDCatBroker
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblCatBrokers]','[Procom].[spIUCatBrokers]','INSERT',@NewJSON,''	

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
			select @OldJSON =  a.JSON from [Procom].[TblCatBrokers] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDCatBroker = @IDCatBroker

			UPDATE [Procom].[TblCatBrokers]    
			SET 
			  Codigo			= UPPER(@Codigo)
			  ,Nombre			=UPPER(@Nombre)
			WHERE  IDCatBroker = @IDCatBroker

			select @NewJSON =  a.JSON from [Procom].[TblCatBrokers] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDCatBroker = @IDCatBroker
	 
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblCatBrokers]','[Procom].[spIUCatBrokers]','UPDATE',@NewJSON,@OldJSON
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
