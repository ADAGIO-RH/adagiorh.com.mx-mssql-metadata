USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Firma de documentos (Avisos de privacidad - Terminos y condiciones)
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-16
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROC [Legal].[spIFirmarDocumentos](
	@JsonFirmas NVARCHAR(MAX),
	@IDUsuario INT
)
AS
	SET NOCOUNT ON

	DECLARE @fechaHoy DATETIME = GETDATE();	
	DECLARE @cont INT = 1;
	DECLARE @noFirmas INT = 0;

	DECLARE @TblFirmas TABLE(
		ID INT IDENTITY(1,1),
		IDDocumento INT,
		IDVersionDocumento INT,
		IsFirmado BIT
	)

	BEGIN TRY
			
		INSERT INTO @TblFirmas
		SELECT * 
		FROM OPENJSON ( @JsonFirmas )  
		WITH (
				IDDocumento INT '$.IDDocumento',
				IDVersionDocumento INT '$.IDVersionDocumento',
				IsFirmado BIT '$.IsFirmado' 
				)
				
		SELECT @noFirmas = COUNT(*) FROM @TblFirmas
		WHILE(@cont <= @noFirmas) 
			BEGIN
						
				BEGIN TRAN

					DECLARE @IDDocumento INT = 0;
					DECLARE @IDVersionDocumento INT = 0;
					DECLARE @IsFirmado BIT = 0;

					SELECT @IDDocumento = IDDocumento, 
							@IDVersionDocumento = IDVersionDocumento,
							@IsFirmado = IsFirmado
					FROM @TblFirmas WHERE ID = @cont;
					
					IF NOT EXISTS(SELECT * FROM [Legal].[tblFirmas] WHERE IDDocumento = @IDDocumento AND IDVersionDocumento = @IDVersionDocumento AND IDUsuario = @IDUsuario)
						BEGIN
							
							DECLARE @IDFirma INT = 0;
							DECLARE @NewJSON VARCHAR(MAX);	

							INSERT INTO [Legal].[tblFirmas](Firma, Fecha, IDDocumento, IDVersionDocumento, IDUsuario)
							VALUES (@IsFirmado, @fechaHoy, @IDDocumento, @IDVersionDocumento, @IDUsuario)


							/* BITACORA AUDITORIA */

							SET @IDFirma = @@identity  

							SELECT @NewJSON = A.JSON 
							FROM [Legal].[tblFirmas] F
								CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT F.* FOR XML RAW)) ) A
							WHERE F.IDFirma = @IDFirma
														
							EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Legal].[tblFirmas]', '[Legal].[spIFirmarDocumentos]', 'INSERT', @NewJSON, ''

							/* FIN DE BITACORA */
						END

					SET @cont += 1;

					IF @@ROWCOUNT = 1
						COMMIT TRAN
				ELSE
					ROLLBACK TRAN 
			END				

	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
GO
