USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarDireccion] --'hidal'
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
			 UPPER(coalesce(d.Pais,'')+', '+ coalesce(d.Estado,'')+', '+coalesce(d.Municipio,'') +', '+coalesce(L.Descripcion,'')+', '+coalesce(d.Colonia,'')+', CP:'+coalesce(d.CodigoPostal,'')) as Direccion,
		    isnull(d.IDPais,0) as IDPais,
			UPPER(d.Pais) as Pais,
			isnull(d.IDEstado,0) as IDEstado,
			UPPER(d.Estado)  as Estado,
			isnull(d.IDMunicipio,0) as IDMunicipio,
			UPPER(d.Municipio)  as Municipio,
			isnull(d.IDColonia,0) as IDColonia,
			UPPER(d.Colonia)  as Colonia,
			isnull(d.IDCodigoPostal,0) as IDCodigoPostal,
			d.CodigoPostal,
			isnull(L.IDLocalidad,0) as IDLocalidad,
			UPPER(L.Descripcion) as Localidad
	from Sat.vwDirecciones d
		Left join Sat.tblCatLocalidades L
			on d.IDEstado = L.IDEstado
			 and L.IDLocalidad = d.IDLocalidad
	Where (@Direccion = '""' or contains(d.*, @Direccion)) 
	order by d.Estado asc, d.Municipio asc, d.Colonia asc
END
GO
