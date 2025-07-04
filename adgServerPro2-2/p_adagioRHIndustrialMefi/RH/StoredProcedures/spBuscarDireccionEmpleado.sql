USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: <Procedure para Buscar la dirección del Empleado>
** Autor			: <Aneudy Abreu>
** Email			: <aneudy.abreu@adagio.com.mx>
** FechaCreacion	: <1/1/2018>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2018-06-18		Jose Rafael Roman Gil	Se agrega la ruta de transporte a la direccion del Empleado
***************************************************************************************************/

CREATE PROCEDURE [RH].[spBuscarDireccionEmpleado] --@IDDireccionEmpleado = 15
(
	@IDEmpleado int = 0
	,@IDDireccionEmpleado int = 0
)
AS
BEGIN
		Select 
			DE.IDDireccionEmpleado,
			DE.IDEmpleado,
			isnull(DE.IDPais,0) as IDPais,
			P.Descripcion as Pais,
			isnull(DE.IDEstado,0) as IDEstado,
			isnull(E.NombreEstado,DE.Estado) as Estado,
			isnull(DE.IDMunicipio,0) as IDMunicipio,
			isnull(M.Descripcion,DE.Municipio) as Municipio,
			isnull(DE.IDColonia,0) as IDColonia,
			isnull(C.NombreAsentamiento,DE.Colonia) as Colonia,
			isnull(DE.IDLocalidad,0) as IDLocalidad,
			isnull(L.Descripcion,DE.Localidad) as Localidad,
			isnull(DE.IDCodigoPostal,0) as IDCodigoPostal,
			isnull(CP.CodigoPostal,DE.CodigoPostal) as CodigoPostal,
			DE.Calle,
			DE.Exterior,
			DE.Interior,
			DE.FechaIni,
			DE.FechaFin,
			case when P.Descripcion is not null  then coalesce(P.Descripcion,'') + ', ' else '' end
			    + case when (e.NombreEstado is not null or de.Estado is not null) then  isnull(E.NombreEstado,coalesce(DE.Estado,''))+ ', ' else '' end
			    + case when (M.Descripcion is not null or de.Municipio is not null) then  isnull(M.Descripcion,coalesce(DE.Municipio,''))+ ', ' else '' end
			    + case when (C.NombreAsentamiento is not null or de.Colonia is not null) then  isnull(C.NombreAsentamiento,coalesce(DE.Colonia,''))+ ', ' else '' end
			    + case when (L.Descripcion is not null or de.Localidad is not null) then  isnull(L.Descripcion,coalesce(DE.Localidad,''))+ ', ' else '' end
			    + case when (CP.CodigoPostal is not null or de.CodigoPostal is not null) then  isnull(CP.CodigoPostal,coalesce(DE.CodigoPostal,''))+ ', ' else '' end
			    + case when DE.Calle is not null then DE.Calle+' ' else '' end 
			    + case when DE.Exterior is not null then DE.Exterior +' - ' else '' end
			    + coalesce(DE.Interior,'') as Direccion,

			   			   
			   --isnull(E.NombreEstado,'NINGUNO')+', '+
			   -- isnull(M.Descripcion,'NINGUNO')+', '+
			   -- isnull(C.NombreAsentamiento,'NINGUNO')+', CP:'+isnull(cp.CodigoPostal,'')+', Calle '+
			isnull(DE.IDRuta,0) as IDRuta,
			JSON_VALUE(RT.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Ruta
		From RH.tblDireccionEmpleado DE
			Left join Sat.tblCatCodigosPostales CP
				on CP.IDCodigoPostal = DE.IDCodigoPostal
			Left join Sat.tblCatEstados E
				on DE.IDEstado = E.IDEstado
			Left join Sat.tblCatMunicipios M
				on DE.IDMunicipio = M.IDMunicipio
			Left join Sat.tblCatColonias C
				on DE.IDColonia = C.IDColonia
			Left join Sat.tblCatPaises p 
				on DE.IDPais = p.IDPais
			Left join Sat.tblCatLocalidades L 
				on DE.IDLocalidad = L.IDLocalidad
			Left Join RH.tblCatRutasTransporte RT
				on RT.IDRuta = DE.IDRuta
		WHERE (DE.IDEmpleado = @IDEmpleado and @IDDireccionEmpleado=0)
		  or (DE.IDDireccionEmpleado = @IDDireccionEmpleado AND @IDEmpleado=0)
		ORDER BY DE.FechaIni DESC
END	


-- México, Jalisco, Zapopan, El Centinela, CP:45133, ACANTILADO 2880-36B
GO
