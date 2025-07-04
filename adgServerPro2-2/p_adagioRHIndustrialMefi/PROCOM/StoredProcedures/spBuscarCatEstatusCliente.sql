USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBuscarCatEstatusCliente(
	@IDCatEstatusCliente int = 0,
	@IDUsuario int
)
AS
BEGIN
	SELECT IDCatEstatusCliente
		,Descripcion
	FROM Procom.tblCatEstatusCliente
	WHERE ((IDCatEstatusCliente = @IDCatEstatusCliente) or (isnull(@IDCatEstatusCliente , 0) = 0))
	ORDER BY IDCatEstatusCliente ASC
END
GO
