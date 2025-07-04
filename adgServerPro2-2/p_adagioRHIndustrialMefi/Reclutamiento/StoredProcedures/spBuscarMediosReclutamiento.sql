USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Reclutamiento.spBuscarMediosReclutamiento(
	@IDMedioReclutamiento int = 0,
	@SoloActivos bit = 0,
	@IDUsuario int
) as
	declare 
		@IDTipoCatalogo int = 7 -- Tipos de medios de reclutamiento
	;

	select 
		mr.IDMedioReclutamiento
		,mr.Nombre
		,mr.IDTipoMedioReclutamiento
		,tiposMedios.Catalogo as TipoMedioReclutamiento
		,mr.Activo
	from Reclutamiento.tblMediosReclutamiento mr
		left join (
			select * 
			from App.tblCatalogosGenerales cg
			where IDTipoCatalogo = @IDTipoCatalogo
		) tiposMedios on tiposMedios.IDCatalogoGeneral = mr.IDTipoMedioReclutamiento
	where (mr.IDMedioReclutamiento = @IDMedioReclutamiento or isnull(@IDMedioReclutamiento, 0) = 0)
		and (mr.Activo = case when isnull(@SoloActivos, 0) = 1 then 1 else mr.Activo end)
GO
