USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Insertar o actualizar porcentajes
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-28
** Paremetros		: @IDPorcentaje			- Identificador del porcentaje.
					  @Porcentaje			- Numero de porcentaje.
					  @Activo				- Bandera que habilita o inhabilita el porcentaje.
					  @IDUsuario			- Identificador de usuario
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spIUPorcentaje](
	@IDPorcentaje	INT = 0
	,@Porcentaje	INT = 0
	,@Activo		BIT = 0
	,@IDUsuario	BIT = 0
)
AS
	
	SET FMTONLY OFF;

	DECLARE @OldJSON VARCHAR(MAX)
			,@NewJSON VARCHAR(MAX)
			,@NO_EXISTE BIT = 0
			;


	BEGIN TRY	
		
		BEGIN TRAN

			IF (@Porcentaje < 0 OR @Porcentaje > 100)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700001'
				RETURN;
			END


			IF(@IDPorcentaje = 0)
				BEGIN			

					IF EXISTS(SELECT TOP 1 1 FROM [Staffing].[tblCatPorcentajes] WHERE Porcentaje = @Porcentaje)
						BEGIN
							EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700002'
							RETURN;
						END				

					SET @Activo = 1;

					INSERT INTO [Staffing].[tblCatPorcentajes] VALUES(@Porcentaje, @Activo)
					SET @IDPorcentaje = @@IDENTITY

					IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN 

					SELECT @NewJSON = a.JSON FROM [Staffing].[tblCatPorcentajes] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
					WHERE b.IDPorcentaje = @IDPorcentaje;

					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatPorcentajes]', '[Staffing].[spIUPorcentaje]', 'INSERT', @NewJSON, '';

					EXEC [Staffing].[spBuscarPorcentajes] @IDPorcentaje	  = 0
															, @Porcentaje	  = 0
															, @Activo		  = 1
															, @IDUsuario	  = @IDUsuario			
				END
			ELSE
				BEGIN

					IF EXISTS(SELECT IDPorcentaje FROM [Staffing].[tblCatPorcentajes] WHERE IDPorcentaje = @IDPorcentaje)
						BEGIN					

							IF EXISTS(SELECT TOP 1 1 FROM [Staffing].[tblCatPorcentajes] WHERE IDPorcentaje <> @IDPorcentaje AND Porcentaje = @Porcentaje)
								BEGIN
									EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700002'
									RETURN;
								END										

							SELECT @OldJSON = a.JSON FROM [Staffing].[tblCatPorcentajes] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDPorcentaje = @IDPorcentaje;
							
							UPDATE [Staffing].[tblCatPorcentajes]
								SET Porcentaje = @Porcentaje,
									Activo = @Activo
								WHERE IDPorcentaje = @IDPorcentaje

							IF @@ROWCOUNT = 1
								COMMIT TRAN
							ELSE
								ROLLBACK TRAN 

							SELECT @NewJSON = a.JSON FROM [Staffing].[tblCatStaff] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDPorcentaje = @IDPorcentaje;

							EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatPorcentajes]', '[Staffing].[spIUPorcentaje]', 'UPDATE', @NewJSON, @OldJSON

							EXEC [Staffing].[spBuscarPorcentajes] @IDPorcentaje	  = 0
															, @Porcentaje	  = 0
															, @Activo		  = 1
															, @IDUsuario	  = @IDUsuario
						END
					ELSE
						BEGIN							
							EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700003'
							RETURN;
						END
				END

	END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT ERROR_MESSAGE() AS ErrorMessage;
		END CATCH
GO
