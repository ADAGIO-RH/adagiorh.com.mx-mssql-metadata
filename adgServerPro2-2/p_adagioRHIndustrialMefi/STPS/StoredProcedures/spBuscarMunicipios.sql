USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarMunicipios]
(
	@IDEstado int = null
)
AS
BEGIN
	Select 
		IDMunicipio
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		,IDEstado 
	from STPS.tblCatMunicipios
	where IDEstado = @IDEstado or @IDEstado is null
	order by cast(Codigo as int) asc
END
GO
