USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spCompletePlaza](
	@IDReferencia int,
	@IDUsuario int
)
AS
BEGIN
	insert RH.tblEstatusPlazas(IDPlaza, IDEstatus, IDUsuario)
	select @IDReferencia,(select IDCatalogoGeneral 
								from [App].[tblCatalogosGenerales] CG With(Nolock)
									inner join [App].[TblTiposCatalogosGenerales] TCG With(Nolock)
										on CG.IDTipoCatalogo = TCG.IDTipoCatalogo
								where TCG.TipoCatalogo = 'Estatus de plazas'
								and CG.Catalogo = 'Autorizada'),@IDUsuario

	
END;
GO
