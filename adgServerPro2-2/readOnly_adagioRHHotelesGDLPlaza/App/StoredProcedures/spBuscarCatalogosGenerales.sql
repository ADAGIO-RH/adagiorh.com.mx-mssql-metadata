USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [App].[spBuscarCatalogosGenerales](
	@IDTipoCatalogo int
) as
	select 
		IDCatalogoGeneral
		,IDTipoCatalogo
		,Catalogo
	from [App].[tblCatalogosGenerales]
	where IDTipoCatalogo = @IDTipoCatalogo
GO
