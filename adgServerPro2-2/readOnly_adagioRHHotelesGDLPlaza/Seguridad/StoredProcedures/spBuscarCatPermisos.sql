USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Seguridad.spBuscarCatPermisos
AS
BEGIN
	select 
		A.IDArea
		,A.Descripcion as Area
		,M.IDModulo
		,M.Descripcion Modulo
		,ISNULL(U.IDUrl,0) as IDUrl
		,U.URL as URL
		,U.Descripcion as Accion
		,U.Tipo
	From App.tblCatAreas A
	left join App.tblCatModulos M
		on A.IDArea = M.IDArea
	left join App.tblCatUrls U
		on M.IDModulo = U.IDModulo
	order by A.Descripcion desc		
END
GO
