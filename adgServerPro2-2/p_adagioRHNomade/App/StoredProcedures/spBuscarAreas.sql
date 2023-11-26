USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarAreas]
AS
BEGIN
	Select ca.IDArea,Descripcion, PrefijoURL, aa.IDAplicacion
	from App.tblCatAreas ca 
	left join App.tblAplicacionAreas  aa on ca.IDArea = aa.IDArea

END
GO
