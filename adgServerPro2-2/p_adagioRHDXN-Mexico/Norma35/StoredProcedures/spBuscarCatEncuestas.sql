USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Norma35.spBuscarCatEncuestas
AS
BEGIN
	SELECT IDCatEncuesta, Nombre, Descripcion 
	FROM Norma35.tblCatEncuestas
	 
END
GO
