USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spUAprobacion](
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

	update Docs.tblAprobadoresDocumentos
		set Aprobacion = @Aprobacion,
			Observacion = UPPER(@Observacion),
			FechaAprobacion = getdate()
	where IDDocumento = @IDDocumento
	and Secuencia = @SecuenciaMax
	and IDUsuario = @IDUsuario

	IF(@Aprobacion = 1)
	BEGIN

		IF NOT EXISTS(select top 1 1 from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and Aprobacion <> 1 and Secuencia = @SecuenciaMax)
		BEGIN
			exec [Docs].[spAsignarEmpleadosADocumentosPorFiltro] @IDDocumento
		END ELSE
		BEGIN
		
			EXEC [App].[INotificacionModuloDocumentos] @IDDocumento,'CREATE-AUTORIZA'
		END
	END


END;
GO
