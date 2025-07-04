USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spBuscarConfiguracionCatalogos
(
	@IDCatalogo int = 0,
	@IDCliente int 
)
AS
BEGIN
	Select
		 cc.IDCliente 
		,cc.IDCatalogo
		,c.Catalogo
		,cc.IDValue
		,cc.Visible
		,cc.Habilitado
	From App.tblConfiguracionCatalogos cc
		inner join app.tblCatCatalogos c
			on CC.IDCatalogo = c.IDCatalogo
	Where cc.IDCliente = @IDCliente
	AND ((cc.IDCatalogo = @IDCatalogo) or (@IDCatalogo = 0))
END
GO
