USE [p_adagioRHIndustrialMefi]
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
					  @IDSucursal			- Identificador de la sucursal.
					  @PorcentajeInicial	- Rango inicial del porcentaje.
					  @PorcentajeFinal		- Rango final del porcentaje.
					  @Activo				- Bandera que habilita o inhabilita el porcentaje.
					  @IDUsuario			- Identificador de usuario
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spIUPorcentaje](
	@IDPorcentaje		INT = 0
	,@IDSucursal		INT = 0
	,@PorcentajeInicial	INT = 0
	,@PorcentajeFinal	INT = 0
	,@Activo			BIT = 0
	,@IDUsuario			BIT = 0
)
AS
	
	SET FMTONLY OFF;

	DECLARE @OldJSON VARCHAR(MAX)
			,@NewJSON VARCHAR(MAX)
			,@NO_EXISTE BIT = 0
			,@Error VARCHAR(MAX)
			;


	BEGIN TRY	
		
		BEGIN TRAN					

			IF (@PorcentajeInicial < 0 OR @PorcentajeInicial > 100)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700001'
				RETURN;
			END

			IF (@PorcentajeFinal < 0 OR @PorcentajeFinal > 100)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700001'
				RETURN;
			END


			IF(@IDPorcentaje = 0)
				BEGIN

					-- RANGOS ENTRELAZADOS
					IF EXISTS(SELECT TOP 1 1 
							FROM [Staffing].[tblCatPorcentajes] P
							WHERE P.IDSucursal = @IDSucursal AND
									(
									@PorcentajeInicial BETWEEN P.PorcentajeInicial AND P.PorcentajeFinal OR
									@PorcentajeFinal BETWEEN P.PorcentajeInicial AND P.PorcentajeFinal
									))
					BEGIN
						EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700002'
						RETURN;
					END	

					SET @Activo = 1;

					INSERT INTO [Staffing].[tblCatPorcentajes] VALUES(@IDSucursal, @PorcentajeInicial, @PorcentajeFinal, @Activo)
					SET @IDPorcentaje = @@IDENTITY

					IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN 

					SELECT @NewJSON = a.JSON FROM [Staffing].[tblCatPorcentajes] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
					WHERE b.IDPorcentaje = @IDPorcentaje;

					EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Staffing].[tblCatPorcentajes]', '[Staffing].[spIUPorcentaje]', 'INSERT', @NewJSON, '';

					EXEC [Staffing].[spBuscarPorcentajes] @IDSucursal = @IDSucursal
				END
			ELSE
				BEGIN

					IF EXISTS(SELECT IDPorcentaje FROM [Staffing].[tblCatPorcentajes] WHERE IDPorcentaje = @IDPorcentaje)
						BEGIN

							-- RANGOS ENTRELAZADOS
							IF EXISTS(SELECT TOP 1 1 
									FROM [Staffing].[tblCatPorcentajes] P
									WHERE P.IDSucursal = @IDSucursal AND
										  P.IDPorcentaje <> @IDPorcentaje AND
											(
											@PorcentajeInicial BETWEEN P.PorcentajeInicial AND P.PorcentajeFinal OR
											@PorcentajeFinal BETWEEN P.PorcentajeInicial AND P.PorcentajeFinal
											))
							BEGIN
								EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3700002'
								RETURN;
							END	

							SELECT @OldJSON = a.JSON FROM [Staffing].[tblCatPorcentajes] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDPorcentaje = @IDPorcentaje;
							
							UPDATE [Staffing].[tblCatPorcentajes]
								SET PorcentajeInicial = @PorcentajeInicial,
									PorcentajeFinal = @PorcentajeFinal,
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

							EXEC [Staffing].[spBuscarPorcentajes] @IDSucursal = @IDSucursal
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
				SELECT @Error = ERROR_MESSAGE()
				RAISERROR(@Error, 16, 1); 				
		END CATCH
GO
