USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Eliminar mapeo de puestos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-05-30
** Paremetros		: @IDMapeo		- Identificador del mapeo.
					  @IDUsuario	- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spBorrarMapeoPuestos]
(
	@IDMapeo		INT = 0	
	, @IDUsuario	INT = 0
)
AS

	DECLARE @OldJSON VARCHAR(MAX)			
			, @Error VARCHAR(MAX)
			, @EXISTE INT = 0
			;


	BEGIN TRY
		
		IF EXISTS(SELECT IDMapeo FROM [Staffing].[tblCatMapeoPuestos] WHERE IDMapeo = @IDMapeo)
			BEGIN					
				BEGIN TRAN

					SELECT @OldJSON = a.JSON FROM [Staffing].[tblCatMapeoPuestos] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
					WHERE b.IDMapeo = @IDMapeo;

					DELETE [Staffing].[tblCatMapeoPuestos]
					WHERE IDMapeo = @IDMapeo;

					IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN

					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatMapeoPuestos]', '[Staffing].[spBorrarMapeoPuestos]', 'DELETE', '', @OldJSON;

					EXEC [Staffing].[spBuscarMapeoPuestos]		
			END

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
			SELECT @Error = ERROR_MESSAGE()
			RAISERROR(@Error, 16, 1);
	END CATCH
GO
