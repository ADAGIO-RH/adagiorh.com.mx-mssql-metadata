USE [p_adagioRHIndustrialMefi]
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
** Paremetros		: @IDPorcentaje			- Identificador deL porcentaje.
					  @IDSucursal			- Identificador de la sucursal.
					  @IDUsuario			- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spBorrarPorcentaje]
(
	@IDPorcentaje	INT = 0
	, @IDSucursal	INT = 0
	, @IDUsuario	INT = 0
)
AS

	DECLARE @OldJSON VARCHAR(MAX)
			, @IDPorcentajeFK INT = 0
			, @Error VARCHAR(MAX)
			, @EXISTE INT = 0
			;
	

	SELECT TOP 1 @IDPorcentajeFK = IDPorcentaje FROM [Staffing].[tblCatStaff] WHERE IDPorcentaje = @IDPorcentaje;
	
	IF (@IDPorcentajeFK > @EXISTE)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700007'
			RETURN;
		END

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

					EXEC [Staffing].[spBuscarPorcentajes] @IDSucursal = @IDSucursal				
			END

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
			SELECT @Error = ERROR_MESSAGE()
			RAISERROR(@Error, 16, 1);
	END CATCH
GO
