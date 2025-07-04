USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Enrutamiento].[spReiniciarUnidadProceso]
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
	WHERE IDUnidad = @IDUnidad
	and Orden > 1

	update [Enrutamiento].[tblEjecucionUnidadProceso]
		set Realizado = 0
		, FechaHoraRealizacion = null
	WHERE IDRutaUnidadProceso  in (
		select IDRutaUnidadProceso from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = @IDUnidad
	)

	update [Enrutamiento].[tblAutorizacionUnidadProceso]
		set Autorizado = 0
		, FechaHoraAutorizacion = null
	WHERE IDRutaUnidadProceso  in (
		select IDRutaUnidadProceso from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = @IDUnidad
	)

END;
GO
