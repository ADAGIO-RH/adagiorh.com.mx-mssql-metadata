USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spBuscarRutaUnidadProceso]
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
	FROM Enrutamiento.tblRutaUnidadProceso RUP
	WHERE RUP.IDUnidad = @IDUnidad
	ORDER BY RUP.Orden DESC
END
GO
