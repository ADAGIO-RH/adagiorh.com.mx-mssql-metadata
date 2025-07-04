USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Elimina el body del email personalizado.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-09-20
** Paremetros		: @IDCustomer			- Identificador del BodyCustomer 'html'.
					  @IDUsuario			- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2024-11-13			Alejandro Paredes	Se agrego el flujo de la columna personalizada
***************************************************************************************************/
CREATE   PROCEDURE [App].[spBorrarTemplateCustomersEmail]
(
    @IDCustomer INT,
    @IDUsuario INT
)
AS
BEGIN

    DECLARE @OldJSON	VARCHAR(MAX)
			, @Error	NVARCHAR(MAX)
			, @IsValid	BIT = 1
			, @NO		BIT = 0
			;

    BEGIN TRY

		-- Validaciones
		SELECT @IsValid = Personalizado FROM [App].[tblTemplateCustomersEmail] WHERE IDCustomer = @IDCustomer;
		IF (@IsValid = @NO)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0000008'
				RETURN;
			END

        -- Verificar si existe el cliente antes de comenzar la transacción
        IF EXISTS (SELECT 1 FROM [App].[tblTemplateCustomersEmail] WHERE IDCustomer = @IDCustomer)
			BEGIN

				-- Iniciar transacción
				BEGIN TRAN;

				-- Obtener el JSON antes de borrar
				SELECT @OldJSON = a.JSON 
				FROM [App].[tblTemplateCustomersEmail] b
				CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.IDCustomer, REPLACE(CAST(b.BodyCustomer AS VARCHAR(MAX)), '"', '''') AS BodyCustomer, b.PixelesWidth, b.IsAnclado, b.IDTemplateNotificacion, b.IDContainer FOR XML RAW))) a
				WHERE b.IDCustomer = @IDCustomer;

				-- Borrar el registro
				DELETE FROM [App].[tblTemplateCustomersEmail]
				WHERE IDCustomer = @IDCustomer;

				-- Registrar la auditoría
				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[App].[tblTemplateCustomersEmail]', '[App].[spBorrarTemplateCustomersEmail]', 'DELETE', '', @OldJSON;

				-- Confirmar la transacción
				COMMIT TRAN;
			END
		ELSE
		BEGIN		
			-- Establecemos el mensaje de error
			SET @Error = 'El IDCustomer: ' + CAST(@IDCustomer AS VARCHAR(25)) + ' no se encontro.' ;
			RAISERROR(@Error, 16, 1);
			RETURN;
		END
    END TRY
    BEGIN CATCH
        
		-- Hacemos rollback si hay error
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		-- Capturamos el error y lo lanzamos con raiserror
		SET @Error = ERROR_MESSAGE();
		RAISERROR(@Error, 16, 1);

    END CATCH;
END;
GO
