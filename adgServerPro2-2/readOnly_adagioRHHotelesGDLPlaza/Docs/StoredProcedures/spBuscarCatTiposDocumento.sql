USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Docs.spBuscarCatTiposDocumento
(
	@IDTipoDocumento int = 0
)
AS
BEGIN
	SELECT IDTipoDocumento
		,Descripcion
		,ROW_NUMBER()OVER(ORDER BY IDTipoDocumento asc) as ROWNUMBER
	FROM Docs.tblCatTiposDocumento
	WHERE ((IDTipoDocumento = @IDTipoDocumento) OR (ISNULL(@IDTipoDocumento,0) = 0))
END;
GO
