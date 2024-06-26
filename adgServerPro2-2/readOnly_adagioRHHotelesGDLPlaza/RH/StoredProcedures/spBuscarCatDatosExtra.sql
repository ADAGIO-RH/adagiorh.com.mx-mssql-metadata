USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RH.spBuscarCatDatosExtra
(
	@IDDatoExtra int = 0
)
AS
BEGIN
	SELECT 
	IDDatoExtra
	,Nombre
	,Descripcion
	,TipoDato
	,ROWNUMBER = ROW_NUMBER()OVER(ORDER BY Nombre ASC) 
	FROM RH.tblCatDatosExtra
	where (IDDatoExtra = @IDDatoExtra) OR (@IDDatoExtra = 0)
	ORDER BY Nombre
END
GO
