USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Eliminar configuracion de porcentajes
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-18
** Paremetros		: @IDConfiguracion		- Identificador de la configuracion.
					  @IDUsuario			- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spBorrarConfPorcentaje]
(
	@IDConfiguracion INT = 0
	,@IDUsuario		 INT = 0
)
AS	
	
	SET FMTONLY OFF;

	DECLARE @OldJSON VARCHAR(MAX),
			@NewJSON VARCHAR(MAX);		

	BEGIN TRY			

		IF EXISTS(SELECT IDConfiguracion FROM [Staffing].[tblConfPorcentajes] WHERE IDConfiguracion = @IDConfiguracion)
			BEGIN					
				BEGIN TRAN
				
					SELECT @OldJSON = a.JSON FROM [Staffing].[tblConfPorcentajes] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDConfiguracion = @IDConfiguracion;		


					DELETE [Staffing].[tblConfPorcentajes]
					WHERE IDConfiguracion = @IDConfiguracion

				IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblConfPorcentajes]', '[Staffing].[spBorrarConfPorcentaje]', 'DELETE', '', @OldJSON;

			END
		ELSE
			BEGIN
				SELECT 'No existe la configuración'
				RETURN;
		END

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
GO
