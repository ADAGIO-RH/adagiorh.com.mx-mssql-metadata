USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta o actualiza el documentos (Avisos de privacidad - Terminos y condiciones)
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-09
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROC [Legal].[spIUVersionesDocumentos](
	@IDDocumento INT,
	@IDTipoDocumento INT,
	@IDVersionDocumento INT,
	@IDEstatus INT,
	@Template VARCHAR(MAX),
	@IDUsuario INT
)
AS
	DECLARE @borrador  INT = 1;
	DECLARE @publicado INT = 2;
	DECLARE @fechaHoy  DATETIME = GETDATE();
	DECLARE @OldJSONVer VARCHAR(MAX), @NewJSONDoc VARCHAR(MAX), @NewJSONVer VARCHAR(MAX);	

	BEGIN TRY
		IF(@IDDocumento = 0)
			BEGIN
				
				BEGIN TRAN
				
					INSERT INTO [Legal].[tblDocumentos](Fecha, IDTipoDocumento, IDUsuario)
					VALUES (@fechaHoy, @IDTipoDocumento, @IDUsuario)
					SET @IDDocumento = @@IDENTITY; 

					INSERT INTO [Legal].[tblVersionesDocumentos](Template, FechaActualizacion, IDDocumento, IDEstatus)
					VALUES (@Template, @fechaHoy, @IDDocumento, @IDEstatus)
					SET @IDVersionDocumento = @@IDENTITY

				IF @@ROWCOUNT = 1
					COMMIT TRAN
				ELSE
					ROLLBACK TRAN 


				/* BITACORA AUDITORIA */

				SELECT @NewJSONDoc = A.JSON 
				FROM [Legal].[tblDocumentos] D
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT D.* FOR XML RAW)) ) A
				WHERE D.IDDocumento = @IDDocumento
					
				SELECT @NewJSONVer = A.JSON 
				FROM [Legal].[tblVersionesDocumentos] V
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT V.IDVersionDocumento, V.FechaActualizacion, V.IDDocumento, V.IDEstatus FOR XML RAW)) ) A
				WHERE V.IDVersionDocumento = @IDVersionDocumento
					
				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Legal].[tblDocumentos]', '[Legal].[spIUVersionesDocumentos]', 'INSERT', @NewJSONDoc, ''
				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Legal].[tblVersionesDocumentos]', '[Legal].[spIUVersionesDocumentos]', 'INSERT', @NewJSONVer, ''

				/* FIN DE BITACORA */
				
			END 
		ELSE 
			BEGIN
				
					
				SELECT @OldJSONVer = A.JSON 
				FROM [Legal].[tblVersionesDocumentos] V
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT V.IDVersionDocumento, V.FechaActualizacion, V.IDDocumento, V.IDEstatus FOR XML RAW)) ) A
				WHERE V.IDVersionDocumento = @IDVersionDocumento

				BEGIN TRAN

					UPDATE [Legal].[tblVersionesDocumentos]
					SET Template = @Template,
						FechaActualizacion = @fechaHoy,
						IDEstatus = CASE WHEN @IDEstatus = @borrador THEN @borrador ELSE @publicado END
					WHERE IDVersionDocumento = @IDVersionDocumento AND 
							IDDocumento = @IDDocumento

				IF @@ROWCOUNT = 1
					COMMIT TRAN
				ELSE
					ROLLBACK TRAN
						  
				/* BITACORA AUDITORIA */
				SELECT @NewJSONVer = A.JSON 
				FROM [Legal].[tblVersionesDocumentos] V
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT V.IDVersionDocumento, V.FechaActualizacion, V.IDDocumento, V.IDEstatus FOR XML RAW)) ) A
				WHERE V.IDVersionDocumento = @IDVersionDocumento

				EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Legal].[tblVersionesDocumentos]', '[Legal].[spIUVersionesDocumentos]', 'UPDATE', @NewJSONVer, @OldJSONVer

				
			END
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
GO
