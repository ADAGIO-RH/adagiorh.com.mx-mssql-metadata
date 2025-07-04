USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Insertar o actualizar cantidades en los porcentajes del staff
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-18
** Paremetros		: @CodigoSucursal			- Identificador de la sucursal.
					  @CodigoPuesto				- Identificador del puesto.
					  @PorcentajeInicial 		- Rango inicial de porcentaje
					  @PorcentajeFinal 			- Rango final de porcentaje
					  @Cantidad					- Cantidad.
					  @IDUsuario				- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spIUStaff](
	@CodigoSucursal			VARCHAR(20)
	,@CodigoDepartamento	VARCHAR(20)
	,@CodigoPuesto			VARCHAR(20)
	,@PorcentajeInicial		INT = 0
	,@PorcentajeFinal		INT = 0
	,@Cantidad				INT = 0
	,@IDUsuario				INT = 0
)
AS
	
	SET FMTONLY OFF;

	DECLARE @OldJSON VARCHAR(MAX)
			,@NewJSON VARCHAR(MAX)
			,@IDStaff INT = 0
			,@IDMapeo INT = 0
			,@IDSucursal INT = 0
			,@IDDepartamento INT = 0
			,@IDPuesto INT = 0	
			,@IDPorcentaje INT = 0
			,@NO_EXISTE BIT = 0
			,@Error VARCHAR(MAX)
			;
	
	
	-- VALIDACION DE SUCURSAL Y PUESTO
	SELECT @IDSucursal = IDSucursal FROM [RH].[tblCatSucursales] WHERE Codigo = @CodigoSucursal;	
	SELECT @IDDepartamento = IDDepartamento FROM [RH].[tblCatDepartamentos] WHERE Codigo = @CodigoDepartamento;
	SELECT @IDPuesto = IDPuesto FROM [RH].[tblCatPuestos] WHERE Codigo = @CodigoPuesto;
	SELECT @IDPorcentaje = IDPorcentaje FROM [Staffing].[tblCatPorcentajes] WHERE IDSucursal = @IDSucursal AND PorcentajeInicial = @PorcentajeInicial AND PorcentajeFinal = @PorcentajeFinal;
	SELECT @IDMapeo = IDMapeo FROM [Staffing].[tblCatMapeoPuestos] WHERE IDSucursal = @IDSucursal AND IDDepartamento = @IDDepartamento AND IDPuesto = @IDPuesto;
	SELECT @IDStaff = IDStaff FROM [Staffing].[tblCatStaff] WHERE IDMapeo = @IDMapeo AND IDPorcentaje = @IDPorcentaje;
	
	
	IF (@IDSucursal = @NO_EXISTE)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700004'
			RETURN;
		END

	IF (@IDDepartamento = @NO_EXISTE)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700006'
			RETURN;
		END

	IF (@IDPuesto = @NO_EXISTE)
		BEGIN		
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700005'
			RETURN;
		END
		

	IF (@IDPorcentaje = @NO_EXISTE)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700003'
			RETURN;
		END
	

	BEGIN TRY

		IF(@IDStaff = 0)
			BEGIN			
			
				BEGIN TRAN
					
					INSERT INTO [Staffing].[tblCatStaff] VALUES(@IDMapeo, @IDPorcentaje, @Cantidad)
					SET @IDStaff = @@IDENTITY

					IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN 

					SELECT @NewJSON = a.JSON FROM [Staffing].[tblCatStaff] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
					WHERE b.IDStaff = @IDStaff;

					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatStaff]', '[Staffing].[spIUStaff]', 'INSERT', @NewJSON, '';					
					
			END
		ELSE
			BEGIN
				
				IF EXISTS(SELECT IDStaff FROM [Staffing].[tblCatStaff] WHERE IDStaff = @IDStaff)
					BEGIN
						
						BEGIN TRAN						

							SELECT @OldJSON = a.JSON FROM [Staffing].[tblCatStaff] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDStaff = @IDStaff;					
				
							UPDATE [Staffing].[tblCatStaff]
								SET Cantidad = @Cantidad
								WHERE IDStaff = @IDStaff

							IF @@ROWCOUNT = 1
								COMMIT TRAN
							ELSE
								ROLLBACK TRAN 

							SELECT @NewJSON = a.JSON FROM [Staffing].[tblCatStaff] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDStaff = @IDStaff;

							EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatStaff]', '[Staffing].[spIUStaff]', 'UPDATE', @NewJSON, @OldJSON
							
					END
			END

	END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT @Error = ERROR_MESSAGE()
			RAISERROR(@Error, 16, 1); 				
		END CATCH
GO
