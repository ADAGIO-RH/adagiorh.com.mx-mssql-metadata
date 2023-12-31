USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spUAprobacionPosicion]
(
	@IDAprobadorPosicion int,
	@IDPosicion int,
	@Aprobacion int,
	@Observacion varchar(max),
	@IDUsuario int
)
AS
BEGIN

DECLARE @CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0

	select @SecuenciaMax = isnull(MAX(isnull(Secuencia,0)),0) from RH.tblAprobadoresPosiciones where IDPosicion = @IDPosicion

	update RH.tblAprobadoresPosiciones 
		set Aprobacion = @Aprobacion,
			Observacion = UPPER(@Observacion),
			FechaAprobacion = getdate()
	where  IDPosicion = @IDPosicion
	and Secuencia = @SecuenciaMax
	and IDUsuario = @IDUsuario

	IF(@Aprobacion = 1)
	BEGIN

		IF NOT EXISTS(select top 1 1 from RH.tblAprobadoresPosiciones where IDPosicion = @IDPosicion and Aprobacion <> 1 and Secuencia = @SecuenciaMax)
		BEGIN
			--select 'complete'
			EXEC [App].[INotificacionModuloPosiciones]0, @IDPosicion,'COMPLETE-SECUENCIA'

			-- Estatus de autorizada
			insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario)
			select @IDPosicion,2,@IDUsuario

			--EXEC [Docs].[spAsignarEmpleadosADocumentosPorFiltro] @IDDocumento

		END ELSE
		BEGIN
			EXEC [App].[INotificacionModuloPosiciones]0, @IDPosicion,'CREATE-AUTORIZA'
		END
	END

	IF(@Aprobacion = 2)
	BEGIN
		EXEC [App].[INotificacionModuloPosiciones] @IDAprobadorPosicion, @IDPosicion,'DECLINE-AUTORIZA'
		-- Estatus de autorizada
		insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario)
		select @IDPosicion,5,@IDUsuario

	END


END;
GO
