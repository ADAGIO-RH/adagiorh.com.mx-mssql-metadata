USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Enrutamiento].[spBuscarRutaUnidadProcesoEjecuciones]
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
		,isnull(EUP.Realizado,0) as Realizado
		,CASE WHEN isnull(EUP.Realizado,0) = 0 THEN 'NO'
			ELSE 'SI'
			END RealizadoStr
		,ISNULL(EUP.FechaHoraRealizacion,'9999-12-31') as FechaHoraRealizacion
		,isnull(EUP.IDUsuario,0) as IDUsuario
		,COALESCE(U.Cuenta,'')+' - '+COALESCE(U.Nombre,'')+' '+ COALESCE(U.Apellido,'') as Usuario
	FROM Enrutamiento.tblRutaUnidadProceso RUP
		left join Enrutamiento.tblEjecucionUnidadProceso EUP
			on EUP.IDRutaUnidadProceso = RUP.IDRutaUnidadProceso
		left join Seguridad.tblUsuarios U
			on U.IDUsuario = EUP.IDUsuario
	WHERE RUP.IDUnidad = @IDUnidad
	ORDER BY RUP.Orden DESC
END
GO
