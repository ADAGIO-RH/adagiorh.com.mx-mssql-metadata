USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Enrutamiento].[spRetrasarPasoUnidadProceso]
(
	@IDUnidad int,
	@IDUsuario int
)
AS
BEGIN
DECLARE @IDRutaUnidadProceso int
	UPDATE [Enrutamiento].[tblUnidadProceso]
		set IDEstatus = (select IDCatalogoGeneral from [App].[tblCatalogosGenerales] CG With(Nolock)
				where  CG.IDTipoCatalogo = 6
				and CG.Catalogo = 'En Proceso')
	WHERE IDUnidad = @IDUnidad

	Select top 1 @IDRutaUnidadProceso = IDRutaUnidadProceso 
	from [Enrutamiento].[tblRutaUnidadProceso] RUP 
	where RUP.IDUnidad = @IDUnidad and Completado = 1 
	order by Orden desc

	update  [Enrutamiento].[tblRutaUnidadProceso]
		set Completado = 0
		, FechaHoraCompletado = null
	WHERE IDRutaUnidadProceso = @IDRutaUnidadProceso

	update [Enrutamiento].[tblEjecucionUnidadProceso]
		set Realizado = 0
		, FechaHoraRealizacion = null
	WHERE IDRutaUnidadProceso = @IDRutaUnidadProceso

	update [Enrutamiento].[tblAutorizacionUnidadProceso]
		set Autorizado = 0
		, FechaHoraAutorizacion = null
	WHERE IDRutaUnidadProceso = @IDRutaUnidadProceso

END
GO
