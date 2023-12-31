USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Eliminar porcentajes
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-29
** Paremetros		: @IDDireccion			- Identificador de la dirección.
					  @IDUsuario			- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spBorrarPorcentaje]
(
	@IDPorcentaje INT
	, @IDUsuario INT
)
AS

	DECLARE @OldJSON VARCHAR(MAX);

	BEGIN TRY

		IF EXISTS(SELECT IDPorcentaje FROM [Staffing].[tblCatPorcentajes] WHERE IDPorcentaje = @IDPorcentaje)
			BEGIN					
				BEGIN TRAN

					SELECT @OldJSON = a.JSON FROM [Staffing].[tblCatPorcentajes] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
					WHERE b.IDPorcentaje = @IDPorcentaje;

					DELETE [Staffing].[tblCatPorcentajes]
					WHERE IDPorcentaje = @IDPorcentaje

					IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN

					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatPorcentajes]', '[Staffing].[spBorrarPorcentaje]', 'DELETE', '', @OldJSON;

					EXEC [Staffing].[spBuscarPorcentajes] @IDPorcentaje	  = 0
														  , @Porcentaje	  = 0
														  , @Activo		  = 1
														  , @IDUsuario	  = @IDUsuario					
			END

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
GO
