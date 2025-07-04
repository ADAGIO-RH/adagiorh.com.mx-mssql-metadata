USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Enrutamiento].[spBuscarRutaUnidadProcesoAutorizaciones]
(
	@IDUnidad int,
	@IDUsuario int
)
AS
BEGIN
	SELECT 
		 RUP.IDRutaUnidadProceso
		,RUP.IDUnidad
		,RUP.IDCatRuta
		,RUP.Ruta
		,RUP.IDCatTipoProceso
		,RUP.TipoProceso
		,RUP.IDRutaStep
		,RUP.IDCatTipoStep
		,RUP.TipoStep
		,RUP.Orden
		,RUP.Completado
		,CASE WHEN isnull(RUP.Completado,0) = 0 THEN 'NO'
			ELSE 'SI'
			END CompletadoStr
		,ISNULL(RUP.FechaHoraCompletado,'9999-12-31') as FechaHoraCompletado
		,isnull(EUP.IDSecuencia,0) as IDSecuencia
		,isnull(EUP.Autorizado,0) as Autorizado
		,CASE WHEN isnull(EUP.Autorizado,0) = 0 THEN 'PENDIENTE'
			WHEN isnull(EUP.Autorizado,0) = 1 THEN 'AUTORIZADO'
			WHEN isnull(EUP.Autorizado,0) = 2 THEN 'RECHAZADO'
			ELSE 'PENDIENTE'
			END AutorizadoStr
		,ISNULL(EUP.FechaHoraAutorizacion,'9999-12-31') as FechaHoraAutorizacion
		,isnull(EUP.IDUsuario,0) as IDUsuario
		,COALESCE(U.Cuenta,'')+' - '+COALESCE(U.Nombre,'')+' '+ COALESCE(U.Apellido,'') as Usuario
		,EUP.Observacion
	FROM Enrutamiento.tblRutaUnidadProceso RUP
		left join Enrutamiento.tblAutorizacionUnidadProceso EUP
			on EUP.IDRutaUnidadProceso = RUP.IDRutaUnidadProceso
		left join Seguridad.tblUsuarios U
			on U.IDUsuario = EUP.IDUsuario
	WHERE RUP.IDUnidad = @IDUnidad
	ORDER BY RUP.Orden DESC
END;
GO
