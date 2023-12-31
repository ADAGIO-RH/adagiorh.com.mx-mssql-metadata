USE [p_adagioRHNomade]
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
CREATE   PROCEDURE [Staffing].[spIUStaff](
	@CodigoSucursal  VARCHAR(20)
	,@CodigoPuesto	 VARCHAR(20)
	,@Porcentaje	 INT = 0
	,@Cantidad		 INT = 0
	,@IDUsuario		 INT = 0
)
AS
	
	SET FMTONLY OFF;

	DECLARE @OldJSON VARCHAR(MAX)
			,@NewJSON VARCHAR(MAX)
			,@IDConfiguracion INT = 0
			,@IDSucursal INT = 0			
			,@IDPuesto INT = 0			
			,@NO_EXISTE BIT = 0
			;
	

	-- VALIDACION DE SUCURSAL Y PUESTO
	SELECT @IDSucursal = IDSucursal FROM [RH].[tblCatSucursales] WHERE Codigo = @CodigoSucursal;
	SELECT @IDPuesto = IDPuesto FROM [RH].[tblCatPuestos] WHERE Codigo = @CodigoPuesto;
	SELECT @IDConfiguracion = IDConfiguracion FROM [Staffing].[tblCatStaff] WHERE IDSucursal = @IDSucursal AND IDPuesto = @IDPuesto AND Porcentaje = @Porcentaje

	IF (@IDSucursal = @NO_EXISTE)
		BEGIN
			SELECT 'No existe la sucursal'
			RETURN;
		END

	IF (@IDPuesto = @NO_EXISTE)
		BEGIN
			SELECT 'No existe el puesto'
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
					
					INSERT INTO [Staffing].[tblCatStaff] VALUES(@IDSucursal, @IDPuesto, @Porcentaje, @Cantidad)
					SET @IDConfiguracion = @@IDENTITY

					IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN 

					SELECT @NewJSON = a.JSON FROM [Staffing].[tblCatStaff] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
					WHERE b.IDConfiguracion = @IDConfiguracion;

					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatStaff]', '[Staffing].[spIUStaff]', 'INSERT', @NewJSON, '';
			
			END
		ELSE
			BEGIN
				
				IF EXISTS(SELECT IDConfiguracion FROM [Staffing].[tblCatStaff] WHERE IDConfiguracion = @IDConfiguracion)
					BEGIN
						
						BEGIN TRAN						

							SELECT @OldJSON = a.JSON FROM [Staffing].[tblCatStaff] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDConfiguracion = @IDConfiguracion;					
				
							UPDATE [Staffing].[tblCatStaff]
								SET IDSucursal = @IDSucursal,
									IDPuesto = @IDPuesto,
									Porcentaje = @Porcentaje,
									Cantidad = @Cantidad
								WHERE IDConfiguracion = @IDConfiguracion

							IF @@ROWCOUNT = 1
								COMMIT TRAN
							ELSE
								ROLLBACK TRAN 

							SELECT @NewJSON = a.JSON FROM [Staffing].[tblCatStaff] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDConfiguracion = @IDConfiguracion;	

							EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatStaff]', '[Staffing].[spIUStaff]', 'UPDATE', @NewJSON, @OldJSON

					END
			END

	END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT ERROR_MESSAGE() AS ErrorMessage;
		END CATCH
GO
