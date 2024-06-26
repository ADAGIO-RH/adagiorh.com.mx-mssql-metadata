USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarCodigosPostales]
(
	@IDCodigoPostal int = 0,
	@IDEstado int = null,
	@IDMunicipio int = null,
	@IDLocalidad int = null
)
AS
BEGIN
	select 
	IDCodigoPostal
	,CodigoPostal
	,IDEstado
	,IDMunicipio
	,isnull(IDLocalidad,0) as IDLocalidad 
	From [Sat].[tblCatCodigosPostales]
	where (((IDEstado = @IDEstado) OR (@IDEstado is null))
		OR((IDMunicipio = @IDMunicipio) OR (@IDMunicipio is null))
		OR((IDLocalidad = @IDLocalidad) OR (@IDLocalidad is null)))
	and (IDCodigoPostal = @IDCodigoPostal OR isnull(@IDCodigoPostal,0) = 0)
END
GO
