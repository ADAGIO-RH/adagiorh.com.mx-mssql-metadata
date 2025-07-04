USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Eliminar direcciones
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-27
** Paremetros		: @IDDireccion			- Identificador de la dirección.
					  @IDUsuario			- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spBorrarDireccionesOrganizacionales]
(
	@IDDireccion INT,
	@IDUsuario INT
)
AS	

	DECLARE @OldJSON VARCHAR(MAX),
			@NewJSON VARCHAR(MAX);

	BEGIN TRY			

		IF EXISTS(SELECT IDDireccion FROM [RH].[tblCatDireccionesOrganizacionales] WHERE IDDireccion = @IDDireccion)
			BEGIN					
				BEGIN TRAN

					SELECT @OldJSON = a.JSON FROM [RH].[tblCatDireccionesOrganizacionales] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
					WHERE b.IDDireccion = @IDDireccion

					EXEC [RH].[spBuscarDireccionesOrganizacionales] @IDDireccion	= @IDDireccion, 
																	@Codigo			= NULL,
																	@Descripcion	= NULL,
																	@CuentaContable = NULL,
																	@IDUsuario		= @IDUsuario

					DELETE [RH].[tblCatDireccionesOrganizacionales] 
					WHERE IDDireccion = @IDDireccion

				IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[RH].[tblCatDireccionesOrganizacionales]', '[RH].[spBorrarDirecciones]', 'DELETE', '', @OldJSON;

			END

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
GO
