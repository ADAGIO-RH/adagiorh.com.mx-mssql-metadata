USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

	BEGIN TRY
		IF(@IDDocumento = 0)
			BEGIN
				BEGIN TRAN

					INSERT INTO Legal.tblDocumentos(Fecha, IDTipoDocumento, IDUsuario)
					VALUES (@fechaHoy, @IDTipoDocumento, @IDUsuario)

					SET @IDDocumento = @@IDENTITY;

					INSERT INTO Legal.tblVersionesDocumentos(Template, FechaActualizacion, IDDocumento, IDEstatus)
					VALUES (@Template, @fechaHoy, @IDDocumento, @IDEstatus)

				IF @@ROWCOUNT = 1
					COMMIT TRAN
				ELSE
					ROLLBACK TRAN 
			END /*ELSE 
		BEGIN
			BEGIN TRAN
			IF (@IDEstatus = @borrador)
				BEGIN
					UPDATE Legal.tblVersionesDocumentos
					SET
						Template = @Template,
						FechaActualizacion = @FechaActualizacion
					WHERE IDVersionDocumento = @IDVersionDocumento AND IDDocumento = @IDDocumento
			END ELSE IF (@IDEstatus = @publicado)
				BEGIN
					UPDATE Legal.tblVersionesDocumentos
					SET
						Template = @Template,
						FechaActualizacion = @FechaActualizacion,
						IDEstatus = @publicado
						WHERE IDVersionDocumento = @IDVersionDocumento AND IDDocumento = @IDDocumento
				END
			IF @@ROWCOUNT = 1
				COMMIT TRAN
			ELSE
				ROLLBACK TRAN
		END*/
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
GO
