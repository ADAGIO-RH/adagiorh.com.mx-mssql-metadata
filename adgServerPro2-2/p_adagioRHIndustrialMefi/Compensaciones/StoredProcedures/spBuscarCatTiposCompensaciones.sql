USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Compensaciones].[spBuscarCatTiposCompensaciones](
	@IDCatTipoCompensacion int = 0,
	@IDUsuario int
)
AS
BEGIN
	SELECT 
		IDCatTipoCompensacion
		,Codigo
		,Descripcion
		,FullDescripcion = Codigo + ' - ' + Descripcion
	FROM [Compensaciones].[tblCatTiposCompensaciones]
	WHERE IDCatTipoCompensacion = @IDCatTipoCompensacion OR ISNULL(@IDCatTipoCompensacion,0) = 0
	ORDER BY Codigo ASC
END;
GO
