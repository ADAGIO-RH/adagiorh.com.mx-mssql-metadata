USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Insertar o actualizar mapeo de puestos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-05-30
** Paremetros		: @IDMapeo			- Identificador del mapeo.
					  @IDSucursal		- Identificador de la sucursal.
					  @IDDepartamento	- Identificador del departamento.
					  @IDPuesto			- Identificador del puesto.
					  @IDUsuario		- Identificador de usuario
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spIUMapeoPuestos](
	@IDMapeo			INT = 0
	,@IDSucursal		INT = 0
	,@IDDepartamento	INT = 0
	,@IDPuesto			INT = 0	
	,@IDUsuario			INT = 0
)
AS
	
	SET FMTONLY OFF;

	DECLARE @OldJSON VARCHAR(MAX)
			, @NewJSON VARCHAR(MAX)			
			, @Error VARCHAR(MAX)
			;


	BEGIN TRY	
		
		BEGIN TRAN

			IF(@IDMapeo = 0)
				BEGIN

					IF EXISTS(SELECT TOP 1 1 FROM [Staffing].[tblCatMapeoPuestos] WHERE IDSucursal = @IDSucursal AND IDDepartamento = @IDDepartamento AND IDPuesto = @IDPuesto)
						BEGIN
							EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700009'
							RETURN;
						END

					INSERT INTO [Staffing].[tblCatMapeoPuestos] VALUES(@IDSucursal, @IDDepartamento, @IDPuesto)
					SET @IDMapeo = @@IDENTITY

					IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN 

					SELECT @NewJSON = a.JSON FROM [Staffing].[tblCatMapeoPuestos] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
					WHERE b.IDMapeo = @IDMapeo;

					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatMapeoPuestos]', '[Staffing].[spIUMapeoPuestos]', 'INSERT', @NewJSON, '';

					EXEC [Staffing].[spBuscarMapeoPuestos]
				END
			ELSE
				BEGIN

					IF EXISTS(SELECT IDMapeo FROM [Staffing].[tblCatMapeoPuestos] WHERE IDMapeo = @IDMapeo)
						BEGIN

							IF EXISTS(SELECT TOP 1 1 FROM [Staffing].[tblCatMapeoPuestos] WHERE IDMapeo <> @IDMapeo AND IDSucursal = @IDSucursal AND IDDepartamento = @IDDepartamento AND IDPuesto = @IDPuesto)
							BEGIN
								EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700009'
								RETURN 0;
							END

							SELECT @OldJSON = a.JSON FROM [Staffing].[tblCatMapeoPuestos] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDMapeo = @IDMapeo;
							
							UPDATE [Staffing].[tblCatMapeoPuestos]
								SET IDSucursal = @IDSucursal,
									IDDepartamento = @IDDepartamento,
									IDPuesto = @IDPuesto
								WHERE IDMapeo = @IDMapeo

							IF @@ROWCOUNT = 1
								COMMIT TRAN
							ELSE
								ROLLBACK TRAN 

							SELECT @NewJSON = a.JSON FROM [Staffing].[tblCatMapeoPuestos] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDMapeo = @IDMapeo;

							EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatMapeoPuestos]', '[Staffing].[spIUMapeoPuestos]', 'UPDATE', @NewJSON, @OldJSON

							EXEC [Staffing].[spBuscarMapeoPuestos]
						END
					ELSE
						BEGIN		
							EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700008'
							RETURN;
						END
				END

	END TRY
		BEGIN CATCH
			ROLLBACK TRAN			
				SELECT @Error = ERROR_MESSAGE()
				RAISERROR(@Error, 16, 1); 				
		END CATCH
GO
