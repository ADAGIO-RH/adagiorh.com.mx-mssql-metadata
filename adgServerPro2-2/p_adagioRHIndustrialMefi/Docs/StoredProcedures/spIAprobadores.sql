USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spIAprobadores](
	@IDDocumento int,
	@IDAprobador int,
	@IDUsuario int
)
AS
BEGIN
DECLARE @CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0
	BEGIN TRY
		BEGIN TRAN ADDAPROBADORES
		select @SecuenciaMax = isnull(MAX(isnull(secuencia,0)),0) from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento

		IF(@SecuenciaMax = 0)
		BEGIN
			set @Secuencia = @SecuenciaMax + 1
		END ELSE IF exists( select top 1 1  from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and secuencia = @SecuenciaMax and isnull(Aprobacion,0) = 0)
		BEGIN
			set @Secuencia = @SecuenciaMax
		END
		ELSE
		BEGIN
			set @Secuencia = @SecuenciaMax + 1
		END

		insert into Docs.tblAprobadoresDocumentos(IDDocumento, IDUsuario,Aprobacion, Secuencia)
		Values(@IDDocumento,@IDAprobador,0, @Secuencia)

		Select @CountAprobadores = count(*) from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and Secuencia = @Secuencia

		IF(@CountAprobadores = 1)
		BEGIN
		 EXEC [App].[INotificacionModuloDocumentos] 0,@IDDocumento,'CREATE-AUTORIZA'
		END
		COMMIT TRAN ADDAPROBADORES
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN ADDAPROBADORES;
		THROW
	END CATCH
END;
GO
