USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spCompletePosicion](
	@IDReferencia int,
	@IDUsuario int
)
AS
BEGIN
	insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario)
	select @IDReferencia,(select IDCatalogoGeneral 
								from [App].[tblCatalogosGenerales] CG With(Nolock)
									inner join [App].[TblTiposCatalogosGenerales] TCG With(Nolock)
										on CG.IDTipoCatalogo = TCG.IDTipoCatalogo
								where TCG.TipoCatalogo = 'Estatus de posiciones'
								and CG.Catalogo = 'Autorizada/Disponible'),@IDUsuario

	
END
GO
