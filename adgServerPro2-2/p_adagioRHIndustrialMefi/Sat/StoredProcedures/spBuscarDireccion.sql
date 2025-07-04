USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarDireccion] --'VAL'
(
	@Direccion Varchar(100) = '""'
)
AS
BEGIN

set @Direccion = case 
		when @Direccion is null then '""' 
		when @Direccion = '' then '""'
		when @Direccion = '""' then '""'
	else '"'+@Direccion + '*"' end


	select top 200
			 UPPER(coalesce(p.Descripcion,'')+', '+ coalesce(e.NombreEstado,'')+', '+coalesce(m.Descripcion,'') +', '+coalesce(L.Descripcion,'')+', '+coalesce(c.NombreAsentamiento,'')+', CP:'+coalesce(cp.CodigoPostal,'')) as Direccion,
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
			isnull(L.IDLocalidad,0) as IDLocalidad,
			UPPER(L.Descripcion) as Localidad
	from  Sat.tblCatCodigosPostales CP with(nolock)
	 left join Sat.tblCatColonias C with(nolock)
		on C.IDCodigoPostal = CP.IDCodigoPostal
	 INNER JOIN Sat.tblCatEstados E  with(nolock)
		on E.IDEstado = CP.IDEstado
	left JOIN Sat.tblCatMunicipios M with(nolock)
		on isnull(CP.IDMunicipio,0) = ISNULL(M.IDMunicipio,0)
		and ISNULL(M.IDEstado,0) = ISNULL(E.IDEstado,0)
	INNER JOIN Sat.tblCatPaises P  with(nolock)
		on isnull(P.IDPais,0) = ISNULL(E.IDPais,0)
	Left join Sat.tblCatLocalidades L
			on isnull(cp.IDEstado,0) = isnull(L.IDEstado,0)
			 and isnull(L.IDLocalidad,0) = isnull(cp.IDLocalidad,0)
	Where (@Direccion = '""' or contains(cp.*, @Direccion) or contains(C.*, @Direccion) or contains(E.*, @Direccion)  or contains(m.*, @Direccion)  or contains(p.*, @Direccion)) 
	order by E.NombreEstado asc, m.Descripcion asc, c.NombreAsentamiento asc
END
GO
