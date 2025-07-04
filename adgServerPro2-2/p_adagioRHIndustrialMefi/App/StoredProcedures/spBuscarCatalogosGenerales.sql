USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[spBuscarCatalogosGenerales](
	@IDTipoCatalogo int
) as
	select 
		IDCatalogoGeneral
		,IDTipoCatalogo
		,Catalogo
        ,isnull(s.configuracion,'{}') as configuracion
	from [App].[tblCatalogosGenerales] s
	where IDTipoCatalogo = @IDTipoCatalogo
GO
