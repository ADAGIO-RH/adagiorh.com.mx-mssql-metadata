USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Insertar o actualizar direcciones
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-27
** Paremetros		: @IDDireccion			- Identificador de la dirección.
					  @Codigo				- Codigo de la dirección.
					  @Descripcion			- Descripcion de la dirección.
					  @CuentaContable 		- Cuenta de la dirección.
					  @IDUsuario			- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spIUDireccionOrganizacional](
	@IDDireccion	INT = 0,
	@Codigo			VARCHAR(20),
	@Descripcion	VARCHAR(50),
	@CuentaContable VARCHAR(50),
	@IDUsuario		INT
)
AS

	SET @Codigo         = UPPER(@Codigo)
	SET @Descripcion	= UPPER(@Descripcion)
	SET @CuentaContable	= UPPER(@CuentaContable)
	
	DECLARE @OldJSON VARCHAR(MAX),
			@NewJSON VARCHAR(MAX);

	BEGIN TRY

		IF(@IDDireccion = 0)
			BEGIN			
			
				BEGIN TRAN

					IF EXISTS(SELECT TOP 1 1 FROM [RH].[tblCatDireccionesOrganizacionales] WHERE Codigo = @Codigo)
						BEGIN
							EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
							RETURN;
						END

					INSERT INTO [RH].[tblCatDireccionesOrganizacionales] VALUES(@Codigo, @Descripcion, @CuentaContable)
					SET @IDDireccion = @@IDENTITY

				IF @@ROWCOUNT = 1
					COMMIT TRAN
				ELSE
					ROLLBACK TRAN 

				SELECT @NewJSON = a.JSON FROM [RH].[tblCatDireccionesOrganizacionales] b
				CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
				WHERE b.IDDireccion = @IDDireccion;

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[RH].[tblCatDireccionesOrganizacionales]', '[RH].[spIUDireccion]', 'INSERT', @NewJSON, '';
				
				EXEC [RH].[spBuscarDireccionesOrganizacionales] @IDDireccion	= @IDDireccion, 
																@Codigo			= NULL,
																@Descripcion	= NULL,
																@CuentaContable = NULL,
																@IDUsuario		= @IDUsuario
			END
		ELSE
			BEGIN
				
				IF EXISTS(SELECT IDDireccion FROM [RH].[tblCatDireccionesOrganizacionales] WHERE IDDireccion = @IDDireccion)
					BEGIN
						
						BEGIN TRAN

							IF EXISTS(SELECT TOP 1 1 FROM [RH].[tblCatDireccionesOrganizacionales] WHERE IDDireccion <> @IDDireccion AND Codigo = @Codigo)
							BEGIN
								EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
								RETURN 0;
							END

							SELECT @OldJSON = a.JSON FROM [RH].[tblCatDireccionesOrganizacionales] b
							CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
							WHERE b.IDDireccion = @IDDireccion;						
				
							UPDATE [RH].[tblCatDireccionesOrganizacionales]
								SET Codigo = @Codigo,
									Descripcion = @Descripcion,
									CuentaContable = @CuentaContable
								WHERE IDDireccion = @IDDireccion

						IF @@ROWCOUNT = 1
							COMMIT TRAN
						ELSE
							ROLLBACK TRAN 

						SELECT @NewJSON = a.JSON FROM [RH].[tblCatDireccionesOrganizacionales] b
						CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
						WHERE b.IDDireccion = @IDDireccion;

						EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[RH].[tblCatDireccionesOrganizacionales]', '[RH].[spIUDireccion]', 'UPDATE', @NewJSON, @OldJSON

						EXEC [RH].[spBuscarDireccionesOrganizacionales] @IDDireccion	= @IDDireccion, 
																		@Codigo			= NULL,
																		@Descripcion	= NULL,
																		@CuentaContable = NULL,
																		@IDUsuario		= @IDUsuario
					END
			END

	END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SELECT ERROR_MESSAGE() AS ErrorMessage;
		END CATCH
GO
