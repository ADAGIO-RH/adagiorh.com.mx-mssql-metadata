USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spUAprobacionPlaza]
(
	@IDAprobadorPlaza int,
	@IDPlaza int,
	@Aprobacion int,
	@Observacion varchar(max),
	@IDUsuario int
)
AS
BEGIN

DECLARE @CountAprobadores int = 0,
		@Secuencia int = 0,
		@SecuenciaMax int = 0

	select @SecuenciaMax = isnull(MAX(isnull(Secuencia,0)),0) from RH.tblAprobadoresPlazas where IDPlaza = @IDPlaza

	update RH.tblAprobadoresPlazas 
		set Aprobacion = @Aprobacion,
			Observacion = UPPER(@Observacion),
			FechaAprobacion = getdate()
	where  IDPlaza = @IDPlaza
	and Secuencia = @SecuenciaMax
	and IDUsuario = @IDUsuario

	IF(@Aprobacion = 1)
	BEGIN

		IF NOT EXISTS(select top 1 1 from RH.tblAprobadoresPlazas where IDPlaza = @IDPlaza and Aprobacion <> 1 and Secuencia = @SecuenciaMax)
		BEGIN
			print 1
			--select 'complete'
			EXEC [App].[INotificacionModuloPlazas] @IDAprobadorPlaza, @IDPlaza,'COMPLETE-SECUENCIA'

			-- Estatus de autorizada
			insert RH.tblEstatusPlazas(IDPlaza, IDEstatus, IDUsuario)
			select @IDPlaza,2,@IDUsuario

			EXEC RH.spIniciarProcesoAutorizacionPosicionesPorPlaza @IDPlaza, @IDUsuario
			-- INICIO DE AUTORIZACION DE POSICIONES
			--EXEC [Docs].[spAsignarEmpleadosADocumentosPorFiltro] @IDDocumento

		END ELSE
		BEGIN
			EXEC [App].[INotificacionModuloPlazas] 0,@IDPlaza,'CREATE-AUTORIZA'
		END
	END

	IF(@Aprobacion = 2)
	BEGIN	 
		EXEC [App].[INotificacionModuloPlazas] @IDAprobadorPlaza, @IDPlaza, 'DECLINE-AUTORIZA'

		-- Estatus de No autorizada
		insert RH.tblEstatusPlazas(IDPlaza, IDEstatus, IDUsuario)
		select @IDPlaza,4,@IDUsuario
	END
END;
GO
