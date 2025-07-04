USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarPermisosEspecialesUsuariosTreeView] --5060, 1218
(
	@IDUsuario int,
	@IDUrl int
)
AS
BEGIN
select 
		ROW_NUMBER()over(Order by U.IDUrl) as RN,
		 isnull(PEP.IDPermisoEspecialUsuario,0)as IDPermisoEspecialUsuario
		,isnull(PEP.IDUsuario,@IDUsuario) as IDUsuario
		,ISNULL(U.IDUrl,0) as IDUrl
		,ISNULL(PE.IDPermiso,0) as IDPermiso
		,PE.Codigo as Permiso
		,PE.Descripcion AS Descripcion
		,PEP.TienePermiso as TienePermiso

		
		
	from App.tblCatUrls U
		inner join APP.tblCatPermisosEspeciales PE
			on u.IDUrl = PE.IDUrlParent
		left outer join Seguridad.vwPermisosEspecialesUsuarios PEP
			on PEP.IDPermiso = PE.IDPermiso and PEP.IDUsuario = @IDUsuario
	WHERE U.IDUrl = @IDUrl
		
END
GO
