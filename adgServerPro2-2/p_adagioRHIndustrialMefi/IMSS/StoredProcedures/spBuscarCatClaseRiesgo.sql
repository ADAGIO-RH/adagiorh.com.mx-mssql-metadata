USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarCatClaseRiesgo]
(
	@ClaseRiesgo Varchar(50) = null
)
AS
BEGIN
	select 
	IDClaseRiesgo
	,Codigo
	,Codigo+' - '+Descripcion  as Descripcion
	from [IMSS].[tblCatClaseRiesgo]
	WHERE ((Codigo like @ClaseRiesgo+'%') OR (Descripcion like @ClaseRiesgo+'%')OR(@ClaseRiesgo is null))
	ORDER BY Codigo
END
GO
