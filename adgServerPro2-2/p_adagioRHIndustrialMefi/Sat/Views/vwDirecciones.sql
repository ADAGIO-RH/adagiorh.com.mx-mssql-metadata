USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW  [Sat].[vwDirecciones]
WITH SCHEMABINDING
AS

	select 
		    isnull(P.IDPais,0) as IDPais,
			UPPER(P.Descripcion) COLLATE DATABASE_DEFAULT as Pais,
			isnull(E.IDEstado,0) as IDEstado,
			UPPER(E.NombreEstado) COLLATE DATABASE_DEFAULT as Estado,
			isnull(M.IDMunicipio,0) as IDMunicipio,
			UPPER(M.Descripcion) COLLATE DATABASE_DEFAULT as Municipio,
			isnull(C.IDColonia,0) as IDColonia,
			UPPER(C.NombreAsentamiento) COLLATE DATABASE_DEFAULT as Colonia,
			isnull(CP.IDCodigoPostal,0) as IDCodigoPostal,
			CP.CodigoPostal,
			isnull(cp.IDLocalidad,0) as IDLocalidad
	from Sat.tblCatCodigosPostales CP 
	 left join Sat.tblCatColonias C
		on C.IDCodigoPostal = CP.IDCodigoPostal
	 INNER JOIN Sat.tblCatEstados E 
		on E.IDEstado = CP.IDEstado
	INNER JOIN Sat.tblCatMunicipios M 
		on isnull(CP.IDMunicipio,0) = ISNULL(M.IDMunicipio,0)
		and ISNULL(M.IDEstado,0) = ISNULL(E.IDEstado,0)
	INNER JOIN Sat.tblCatPaises P 
		on isnull(P.IDPais,0) = ISNULL(E.IDPais,0)
GO
