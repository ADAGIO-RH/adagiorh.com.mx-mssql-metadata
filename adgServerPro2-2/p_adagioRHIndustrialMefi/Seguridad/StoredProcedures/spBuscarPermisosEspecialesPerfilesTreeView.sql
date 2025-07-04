USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Seguridad.spBuscarPermisosEspecialesPerfilesTreeView --1, 1218
(
	@IDPerfil int,
	@IDUrl int
)
AS
BEGIN
select 
		ROW_NUMBER()over(Order by U.IDUrl) as RN,
		 isnull(PEP.IDPermisoEspecialPerfil,0)as IDPermisoEspecialPerfil
		,isnull(PEP.IDPerfil,@IDPerfil) as IDPerfil
		,ISNULL(U.IDUrl,0) as IDUrl
		,ISNULL(PE.IDPermiso,0) as IDPermiso
		,PE.Codigo as Permiso
		,PE.Descripcion AS Descripcion
		,cast(case when (PEP.IDPermiso is null) then 0 
			else 1
			end  as bit)as TienePermiso

		
		
	from App.tblCatUrls U
		inner join APP.tblCatPermisosEspeciales PE
			on u.IDUrl = PE.IDUrlParent
		left outer join Seguridad.tblPermisosEspecialesPerfiles PEP
			on PEP.IDPermiso = PE.IDPermiso and PEP.IDPerfil = @IDPerfil
	WHERE U.IDUrl = @IDUrl
		
END
GO
