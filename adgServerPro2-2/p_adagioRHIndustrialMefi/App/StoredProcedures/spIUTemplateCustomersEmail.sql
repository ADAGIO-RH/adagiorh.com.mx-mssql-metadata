USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta o actualiza el body del email personalizado.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-09-12
** Paremetros		: @IDCustomer				Identificador del BodyCustomer 'html'.
**					: @IDTipoNotificacion		Identificador del tipo de notificación.
**					: @IDMedioNotificacion		Identificador del medio de notificacion (Celular, Email, etc).
**					: @IDIdioma					Identificador del idioma.
**					: @BodyCustomer				Codigo html.
**					: @PixelesWidth				Ancho del contenedor html.
**					: @IsAnclado				Bandera que indica si el template es el anclado. (true / false)
**					: @IDUsuario				Identificador del usuario
** IDAzure			: #67

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2024-11-13			Alejandro Paredes	Se agrego el flujo de la columna personalizada
***************************************************************************************************/

CREATE   PROC [App].[spIUTemplateCustomersEmail](
	@IDCustomer				INT
	, @IDTipoNotificacion   VARCHAR(50) = ''
	, @IDMedioNotificacion	VARCHAR(50) = ''
	, @IDIdioma				VARCHAR(10) = ''
	, @BodyCustomer			TEXT = ''
	, @PixelesWidth			INT = 0
	, @IsAnclado			BIT = 0
	, @IDUsuario			INT
)
AS
BEGIN
	-- INICIAMOS LA TRANSACCIÓN
	BEGIN TRANSACTION;

	BEGIN TRY

		-- VARIABLES
		DECLARE @NuevoID					INT = 0
				, @IDTemplateNotificacion	INT = 0
				, @IsValid					BIT = 1
				, @PREFIJO					INT = 2
				, @PERSONALIZADO			BIT = 1
				, @CONTAINER_DEFAULT		INT = 1
				, @SI						BIT = 1
				, @NO						BIT = 0
				, @Error					NVARCHAR(MAX)
				, @OldJSON					VARCHAR(MAX)
				, @NewJSON					VARCHAR(MAX)
				;
		

		-- VALIDACIONES
		SELECT @IsValid = Personalizado FROM [App].[tblTemplateCustomersEmail] WHERE IDCustomer = @IDCustomer;
		IF (@IsValid = @NO)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0000007'
				RETURN;
			END


		-- IDENTIFICAMOS EL IDTemplateNotificacion
		SELECT @IDTemplateNotificacion = IDTemplateNotificacion
		FROM [App].[tblTemplateNotificaciones]
		WHERE IDTipoNotificacion = @IDTipoNotificacion
		  AND IDMedioNotificacion = @IDMedioNotificacion
		  AND IDIdioma = @IDIdioma;


		-- RESETEAMOS EL TEMPLATE ANCLADO
		IF(@IDTemplateNotificacion > 0 AND @IsAnclado = @SI)
		BEGIN
			UPDATE [App].[tblTemplateCustomersEmail]
			SET IsAnclado = @NO
			WHERE IDTemplateNotificacion = @IDTemplateNotificacion;
		END


		-- INSERTE TEMPLATE
		IF(@IDCustomer = 0)
		BEGIN
			IF(@IDTemplateNotificacion > 0)
			BEGIN
			
				-- GENERAR NUEVO ID CON PREFIJO
				EXEC [InfoDir].[fnGenerarNuevoIDConPrefijo] 
					@Prefijo		= @PREFIJO
					, @Tabla		= '[App].[tblTemplateCustomersEmail]'
					, @ColumnaID	= 'IDCustomer'
					, @NuevoID		= @NuevoID OUTPUT
					, @IDUsuario	= @IDUsuario;
				--SELECT @NuevoID AS NuevoID;

				INSERT INTO [App].[tblTemplateCustomersEmail] (IDCustomer, BodyCustomer, PixelesWidth, IsAnclado, Personalizado, IDTemplateNotificacion, IDContainer)
				VALUES (@NuevoID, @BodyCustomer, @PixelesWidth, @IsAnclado, @PERSONALIZADO, @IDTemplateNotificacion, @CONTAINER_DEFAULT);				
				SET @IDCustomer = @NuevoID  

				SELECT @NewJSON = a.JSON FROM [App].[tblTemplateCustomersEmail] b
				CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.IDCustomer, REPLACE(CAST(b.BodyCustomer AS VARCHAR(MAX)), '"', '''') AS BodyCustomer, b.PixelesWidth, b.IsAnclado, b.IDTemplateNotificacion, b.IDContainer FOR XML RAW))) a
				WHERE b.IDCustomer = @IDCustomer;

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[App].[tblTemplateCustomersEmail]', '[App].[spIUTemplateCustomersEmail]', 'INSERT', @NewJSON, '';				

			END
		END
		ELSE
		-- ACTUALIZA TEMPLATE
		BEGIN
			IF EXISTS(SELECT IDCustomer FROM [App].[tblTemplateCustomersEmail] WHERE IDCustomer = @IDCustomer)
			BEGIN		
			
				SELECT @OldJSON = a.JSON FROM [App].[tblTemplateCustomersEmail] b
				CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.IDCustomer, REPLACE(CAST(b.BodyCustomer AS VARCHAR(MAX)), '"', '''') AS BodyCustomer, b.PixelesWidth, b.IsAnclado, b.IDTemplateNotificacion, b.IDContainer FOR XML RAW))) a
				WHERE b.IDCustomer = @IDCustomer;

				UPDATE [App].[tblTemplateCustomersEmail]
				SET BodyCustomer = @BodyCustomer
					, PixelesWidth = @PixelesWidth
					, IsAnclado = @IsAnclado
				WHERE IDCustomer = @IDCustomer;		
				

				SELECT @NewJSON = a.JSON FROM [App].[tblTemplateCustomersEmail] b
				CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.IDCustomer, REPLACE(CAST(b.BodyCustomer AS VARCHAR(MAX)), '"', '''') AS BodyCustomer, b.PixelesWidth, b.IsAnclado, b.IDTemplateNotificacion, b.IDContainer FOR XML RAW))) a
				WHERE b.IDCustomer = @IDCustomer;

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[App].[tblTemplateCustomersEmail]', '[App].[spIUTemplateCustomersEmail]', 'UPDATE', @NewJSON, @OldJSON				

			END
			ELSE
			BEGIN
				-- Establecemos el mensaje de error
				SET @Error = 'El IDCustomer: ' + CAST(@IDCustomer AS VARCHAR(25)) + ' no se encontro.' ;
				RAISERROR(@Error, 16, 1);
				RETURN;
			END
		END

		-- DEVOLVEMOS EL ID
		SELECT IDCustomer
				, BodyCustomer
				, PixelesWidth
				, IsAnclado
				, Personalizado
				, IDTemplateNotificacion
		FROM [App].[tblTemplateCustomersEmail]
		WHERE IDCustomer = @IDCustomer;		
		
		-- SI TODO ES CORRECTO, HACEMOS COMMIT
		COMMIT TRANSACTION;


	END TRY
	BEGIN CATCH

		-- HACEMOS ROLLBACK SI HAY ERROR
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;


		-- CAPTURAMOS EL ERROR Y LO LANZAMOS CON RAISERROR
		SET @Error = ERROR_MESSAGE();
		RAISERROR(@Error, 16, 1);

	END CATCH
END
GO
