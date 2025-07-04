USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarAreaEmpleado](
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
		,UPPER (JSON_VALUE(A.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion'))) as Area 
		,UPPER (JSON_VALUE(A.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion'))) as Descripcion 
	FROM [RH].[tblAreaEmpleado]AE
		INNER JOIN RH.tblCatArea A
			ON AE.IDArea = A.IDArea
	WHERE AE.IDEmpleado = @IDEmpleado
	ORDER BY AE.FechaIni desc
END
GO
