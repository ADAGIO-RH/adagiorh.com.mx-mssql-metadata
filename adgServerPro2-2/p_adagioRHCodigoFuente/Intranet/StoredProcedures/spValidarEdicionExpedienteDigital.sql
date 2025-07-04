USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Valida que el tipo de expediente digital se cargue correctamente.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-02-21
** Paremetros		: @IDExpedienteDigital	- Identificador del tipo de expediente digital.					  
					  @IDUsuario			- Identificador de usuario
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Intranet].[spValidarEdicionExpedienteDigital](
	@IDExpedienteDigital	INT = 0	
	, @IDUsuario			INT = 0
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @Editable BIT = 0	
			, @NO BIT = 0
			, @Error VARCHAR(MAX)
			;


	BEGIN TRY	
		
		BEGIN TRAN		
		
			SELECT @Editable = CAST(JSON_VALUE(IntranetConfig, '$.Editable') AS BIT) 
			FROM [RH].[tblCatExpedientesDigitales] 
			WHERE IDExpedienteDigital = @IDExpedienteDigital;

			IF (@Editable = @NO)
			BEGIN
				RAISERROR('El expediente digital no se encuentra habilitado para edición.', 16, 1);
				ROLLBACK TRAN;
				RETURN;
			END

		COMMIT TRAN;
	END TRY
		BEGIN CATCH
			ROLLBACK TRAN
				SELECT @Error = ERROR_MESSAGE()
				RAISERROR(@Error, 16, 1); 				
		END CATCH
END;
GO
