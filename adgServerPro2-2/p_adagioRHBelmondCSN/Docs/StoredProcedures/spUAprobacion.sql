USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Docs].[spUAprobacion]
(
	@IDAprobadorDocumento int,
	@IDDocumento int,
	@Aprobacion int,
	@Observacion varchar(max),
	@IDUsuario int
)
AS
BEGIN

DECLARE @CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0

	select @SecuenciaMax = isnull(MAX(isnull(secuencia,0)),0) from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento


        IF EXISTS(select top 1 1 from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and Aprobacion = 0 and IDUsuario =@IDUsuario and Secuencia = @SecuenciaMax  )
		BEGIN
            update Docs.tblAprobadoresDocumentos
                set Aprobacion = @Aprobacion,
                    Observacion = UPPER(@Observacion),
                    FechaAprobacion = getdate()
            where IDDocumento = @IDDocumento
            and Secuencia = @SecuenciaMax
            and IDUsuario = @IDUsuario
        END 
		ELSE BEGIN
		
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '3100001'
			RETURN 0;
		END
		
	IF(@Aprobacion = 1)
	BEGIN

		IF NOT EXISTS(select top 1 1 from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and Aprobacion <> 1 and Secuencia = @SecuenciaMax)
		BEGIN
			--select 'complete'
			EXEC [App].[INotificacionModuloDocumentos]0, @IDDocumento,'COMPLETE-SECUENCIA'
			EXEC [Docs].[spAsignarEmpleadosADocumentosPorFiltro] @IDDocumento

		END ELSE
		BEGIN
			EXEC [App].[INotificacionModuloDocumentos]0, @IDDocumento,'CREATE-AUTORIZA'
		END
	END

	IF(@Aprobacion = 2)
	BEGIN
		EXEC [App].[INotificacionModuloDocumentos]@IDAprobadorDocumento,@IDDocumento,'DECLINE-AUTORIZA'
	END


END;
GO
