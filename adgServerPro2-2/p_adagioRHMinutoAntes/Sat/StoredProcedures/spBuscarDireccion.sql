USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarDireccion] --'mexico'
(
	@Direccion Varchar(max) = null
)
AS
BEGIN

	select top 200
			 UPPER(coalesce(p.Descripcion,'')+', '+ coalesce(E.NombreEstado,'')+', '+coalesce(m.Descripcion,'') +', '+coalesce(L.Descripcion,'')+', '+coalesce(C.NombreAsentamiento,'')+', CP:'+coalesce(cp.CodigoPostal,'')) Collate Latin1_General_CI_AI as Direccion,
		    isnull(P.IDPais,0) as IDPais,
			UPPER(P.Descripcion) Collate Latin1_General_CI_AI as Pais,
			isnull(E.IDEstado,0) as IDEstado,
			UPPER(E.NombreEstado) Collate Latin1_General_CI_AI as Estado,
			isnull(M.IDMunicipio,0) as IDMunicipio,
			UPPER(M.Descripcion) Collate Latin1_General_CI_AI as Municipio,
			isnull(C.IDColonia,0) as IDColonia,
			UPPER(C.NombreAsentamiento) Collate Latin1_General_CI_AI as Colonia,
			isnull(CP.IDCodigoPostal,0) as IDCodigoPostal,
			CP.CodigoPostal,
			isnull(L.IDLocalidad,0) as IDLocalidad,
			UPPER(L.Descripcion) Collate Latin1_General_CI_AI as Localidad
	from Sat.tblCatPaises p 
		LEFT join Sat.tblCatEstados E
				on p.IDPais = E.IDPais
		LEFT join Sat.tblCatMunicipios M
				on E.IDEstado = M.IDEstado
		LEFT join Sat.tblCatCodigosPostales CP
			on M.IDMunicipio = CP.IDMunicipio
			and E.IDEstado = CP.IDEstado
		LEFT join Sat.tblCatColonias C
				on CP.IDCodigoPostal = C.IDCodigoPostal
		Left join Sat.tblCatLocalidades L
			on E.IDEstado = L.IDEstado
			 and L.IDLocalidad = CP.IDLocalidad
	Where  (UPPER(coalesce(p.Descripcion,'')+', '+ coalesce(E.NombreEstado,'')+', '+coalesce(m.Descripcion,'') +', '+coalesce(L.Descripcion,'')+', '+coalesce(C.NombreAsentamiento,'')+', CP:'+coalesce(cp.CodigoPostal,'')) Collate Latin1_General_CI_AI like '%'+@Direccion+'%' Collate Latin1_General_CI_AI) OR (@Direccion is null)
	
END
GO
