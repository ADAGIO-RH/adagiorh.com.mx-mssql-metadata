USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatTiposAvisoInfonavit]
AS
BEGIN
	SELECT 
	IDTipoAvisoInfonavit
	,Codigo
	,Clasificacion
	,Descripcion
	,'['+codigo+'] - '+Clasificacion +' - '+ Descripcion as fulltipoAvisoDescripcion
	FROM RH.tblcatTiposAvisosInfonavit
	order by IDTipoAvisoInfonavit asc
END
GO
