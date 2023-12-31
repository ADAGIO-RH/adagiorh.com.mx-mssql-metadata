USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Insertar o actualizar configuracion de porcentajes
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-18
** Paremetros		: @IDConfiguracion			- Identificador de la configuracion.
					  @IDSucursal				- Identificador de la sucursal.
					  @IDPuesto					- Identificador del puesto.
					  @Porcentaje 				- Pordentaje asignado
					  @IDUsuario				- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spIUConfPorcentajes](
	@IDConfiguracion INT = 0
	,@IDSucursal  	 INT = 0
	,@IDPuesto		 INT = 0
	,@Porcentaje	 INT = 0
	,@IDUsuario		 INT = 0
)
AS
	
	SET FMTONLY OFF;

	DECLARE @OldJSON VARCHAR(MAX)
			,@NewJSON VARCHAR(MAX)
			,@ExisteSucursal BIT = 0
			,@ExistePuesto BIT = 0
			,@NO_EXISTE BIT = 0
			;
	

	-- VALIDACION DE SUCURSAL Y PUESTO
	SELECT @ExisteSucursal = CASE WHEN @IDSucursal = IDSucursal THEN 1 ELSE 0 END FROM [RH].[tblCatSucursales] WHERE IDSucursal = @IDSucursal;
	SELECT @ExistePuesto = CASE WHEN @IDPuesto = IDPuesto THEN 1 ELSE 0 END FROM [RH].[tblCatPuestos] WHERE IDPuesto = @IDPuesto;

	IF (@ExisteSucursal = @NO_EXISTE)
		BEGIN
			SELECT 'No existe la sucursal'
			RETURN;
		END

	IF (@ExistePuesto = @NO_EXISTE)
		BEGIN
			SELECT 'No existe el puesto'
			RETURN;
		END

	IF EXISTS(SELECT TOP 1 1 FROM [Staffing].[tblConfPorcentajes] WHERE IDSucursal = @IDSucursal AND IDPuesto = @IDPuesto AND Porcentaje = @Porcentaje)
		BEGIN
			SELECT 'Ya existe este registro'
			RETURN;
		END

	IF (@Porcentaje < 0 OR @Porcentaje > 100)
		BEGIN
			SELECT 'El porcentaje debe estar entre 0 y 100'
			RETURN;
		END


	BEGIN TRY

		IF(@IDConfiguracion = 0)
			BEGIN			
			
				BEGIN TRAN
					
					INSERT INTO [Staffing].[tblConfPorcentajes] VALUES(@IDSucursal, @IDPuesto, @Porcentaje)
					SET @IDConfiguracion = @@IDENTITY

					IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN 

					SELECT @NewJSON = a.JSON FROM [Staffing].[tblConfPorcentajes] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
					WHERE b.IDConfiguracion = @IDConfiguracion;

					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblConfPorcentajes]', '[Staffing].[spIUConfPorcentajes]', 'INSERT', @NewJSON, '';
			
			END
		ELSE
			BEGIN
				
				IF EXISTS(SELECT IDConfiguracion FROM [Staffing].[tblConfPorcentajes] WHERE IDConfiguracion = @IDConfiguracion)
					BEGIN
						
						BEGIN TRAN						

							SELECT @OldJSON = a.JSON FROM [Staffing].[tblConfPorcentajes] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDConfiguracion = @IDConfiguracion;					
				
							UPDATE [Staffing].[tblConfPorcentajes]
								SET IDSucursal = @IDSucursal,
									IDPuesto = @IDPuesto,
									Porcentaje = @Porcentaje
								WHERE IDConfiguracion = @IDConfiguracion

							IF @@ROWCOUNT = 1
								COMMIT TRAN
							ELSE
								ROLLBACK TRAN 

							SELECT @NewJSON = a.JSON FROM [Staffing].[tblConfPorcentajes] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDConfiguracion = @IDConfiguracion;	

							EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblConfPorcentajes]', '[Staffing].[spIUConfPorcentajes]', 'UPDATE', @NewJSON, @OldJSON

					END
			END

	END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT ERROR_MESSAGE() AS ErrorMessage;
		END CATCH
GO
