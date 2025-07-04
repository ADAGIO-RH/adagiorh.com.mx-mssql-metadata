USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spBorrarExperienciaLaboral]
(
	@IDExperienciaLaboral int
	,@IDUsuario int = 0
	,@IDCandidato int = 0
)
AS
BEGIN

		BEGIN TRY  
		  DELETE [Reclutamiento].[tblExperienciaLaboral]
			WHERE [IDExperienciaLaboral] = @IDExperienciaLaboral
		END TRY  
		BEGIN CATCH  
		 DECLARE @ErrorMessage NVARCHAR(4000)
			,@ErrorSeverity INT
			,@ErrorState INT;

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
		END CATCH ;
END
GO
