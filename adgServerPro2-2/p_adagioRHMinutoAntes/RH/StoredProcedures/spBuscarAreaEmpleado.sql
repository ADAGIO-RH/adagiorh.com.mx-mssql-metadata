USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarAreaEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
	SELECT 
	   AE.IDAreaEmpleado
	,AE.IDEmpleado
	,AE.FechaIni
	,AE.FechaFin
	,A.IDArea
	,A.Codigo
	,A.Descripcion as Area
	FROM [RH].[tblAreaEmpleado]AE
		INNER JOIN RH.tblCatArea A
			ON AE.IDArea = A.IDArea
	WHERE AE.IDEmpleado = @IDEmpleado
	ORDER BY AE.FechaIni desc
END
GO
