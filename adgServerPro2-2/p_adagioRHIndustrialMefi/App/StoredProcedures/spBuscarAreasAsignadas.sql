USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [App].[spBuscarAreasAsignadas]
 @IDAplicacion varchar(max) = null
AS
BEGIN
	IF (@IDAplicacion IS NULL)
	BEGIN
		select CA.IDArea,CA.Descripcion
		from [App].[tblCatAreas]   CA
		LEFT JOIN [App].[tblAplicacionAreas] AA on CA.IDArea = AA.IDArea
		WHERE AA.IDAplicacion is null
	END
	ELSE
	BEGIN
		select CA.IDArea,CA.Descripcion
		from [App].[tblAplicacionAreas] AA
		INNER JOIN [App].[tblCatAreas] CA on AA.IDArea = CA.IDArea
		where IDAplicacion = @IDAplicacion
	END

END
GO
