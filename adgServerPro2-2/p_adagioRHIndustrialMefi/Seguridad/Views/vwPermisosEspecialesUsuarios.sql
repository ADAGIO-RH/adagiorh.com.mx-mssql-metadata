USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW Seguridad.vwPermisosEspecialesUsuarios
AS

	select 
		c.IDController
	   ,c.Descripcion as Controller
	   ,u.IDUrl
	   ,u.Traduccion as UrlTraduccion
	   ,pe.IDPermiso
	   ,pe.Codigo codigoPermiso
	   ,pe.CodigoParent CodigoParent
	   ,pe.Descripcion DescripcionPermiso
	   --,cast(case when peu.IDPermisoEspecialUsuario is null then 0
			 --else 1
			 --end as bit) TienePermiso 
		,isnull(Perfiles.IDPerfil,0) as IDPerfil
		,isnull(usuarios.IDUsuario,0) as IDUsuario
		,isnull(peu.IDPermisoEspecialUsuario,0) as IDPermisoEspecialUsuario
		,isnull(pep.IDPermisoEspecialPerfil,0) as IDPermisoEspecialPerfil
		,TienePermiso = CAST(CASE WHEN (isnull(peu.IDPermisoEspecialUsuario,0) > 0) OR isnull(pep.IDPermisoEspecialPerfil,0)> 0 THEN 1
			else 0
			END as bit)
      
	from app.tblCatControllers c  with(nolock)
		inner join app.tblCatUrls u   with(nolock) on c.IDController = u.IDController
		inner join app.tblCatPermisosEspeciales pe  with(nolock) on u.IDUrl = pe.IDUrlParent
		CROSS APPLY Seguridad.tblCatPerfiles perfiles with(nolock)
		CROSS APPLY Seguridad.tblUsuarios usuarios with(nolock)
		left join Seguridad.tblPermisosEspecialesPerfiles pep with(nolock)
			on pep.IDPerfil = perfiles.IDPerfil
			and pep.IDPermiso = pe.IDPermiso
		
		left join Seguridad.tblPermisosEspecialesUsuarios peu on peu.IDPermiso = pe.IDPermiso
			 and peu.IDUsuario = usuarios.IDUsuario
	where 
		perfiles.IDPerfil = usuarios.IDPerfil
GO
