USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spCancelarUnidadProceso]
(
	@IDUnidad int,
	@IDUsuario int
)
AS
BEGIN
	UPDATE [Enrutamiento].[tblUnidadProceso]
		set IDEstatus = (select IDCatalogoGeneral from [App].[tblCatalogosGenerales] CG With(Nolock)
				where  CG.IDTipoCatalogo = 6
				and CG.Catalogo = 'Cancelada')
	WHERE IDUnidad = @IDUnidad
END
GO
