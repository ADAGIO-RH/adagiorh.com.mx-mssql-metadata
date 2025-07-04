USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Sat].[spBuscarTiposIncapacidad]
(
	@IDTIpoIncapacidad int = 0
)
AS
BEGIN
	IF(@IDTIpoIncapacidad = 0 or @IDTIpoIncapacidad is null)
	BEGIN
		select 
			IDTIpoIncapacidad
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatTiposIncapacidad]
	END
	ELSE
	BEGIN
		select 
			IDTIpoIncapacidad
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [Sat].[tblCatTiposIncapacidad]
		where (IDTIpoIncapacidad = @IDTIpoIncapacidad) or (IDTIpoIncapacidad = @IDTIpoIncapacidad)
	END
END
GO
