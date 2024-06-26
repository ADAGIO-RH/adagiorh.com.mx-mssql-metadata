USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Asistencia.spBuscarDiasFestivos
(
	@IDDiaFestivo int = 0
)
AS
BEGIN
	SELECT 
		IDDiaFestivo
		,Fecha
		,FechaReal
		,Descripcion
		,Autorizado
		,ROW_NUMBER() OVER(ORDER BY IDDiaFestivo ASC) as ROWNUMBER
	FROM Asistencia.TblCatDiasFestivos
	WHERE ((IDDiaFestivo = @IDDiaFestivo) OR (ISNULL(@IDDiaFestivo,0) = 0)) 
END
GO
