USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Seguridad].[vwPermisosUsuariosController]
AS
select
	
	a.IDAplicacion    
	,areas.IDArea    
	,areas.Descripcion as Area    
	,c.IDController    
	,c.Nombre as Controller
	,u.IDUrl
	,u.URL
	,u.Traduccion
	,Perfil.IDPerfil
	,perfil.Descripcion as Perfil
	,PermisoPerfil.IDPermisoPerfilController
	,PermisoPerfil.IDTipoPermiso as IDTipoPermisoPerfil
	,usuario.IDUsuario as IDUsuario
	,usuario.Cuenta as Usuario
	,puc.IDPermisoUsuarioController
	,puc.IDTipoPermiso as IDTipoPermisoUsuario
	,puc.PermisoPersonalizado
	,IDTipoPermiso = isnull(CASE WHEN isnull(puc.PermisoPersonalizado,0) = 1 THEN puc.IDTipoPermiso else PermisoPerfil.IDTipoPermiso end,'')
	,PermisosEspeciales =  case when exists (select top 1 1    
			from App.tblCatControllers cc    
			join App.tblCatUrls ur on cc.IDController = ur.IDController and ur.Tipo = 'V'    
			and cc.IDController= c.IDController
			join App.tblCatPermisosEspeciales pe on ur.IDUrl = pe.IDUrlParent    
			) then cast(1 as bit) else cast(0 as bit) end
	--,a.Orden	       
from App.tblCatAplicaciones a 
	inner join App.tblAplicacionAreas AA with(nolock) on A.IDAplicacion = AA.IDAplicacion
	left join App.tblCatAreas areas with(nolock)  on AA.IDArea = areas.IDArea 
	inner join App.tblCatControllers c with(nolock)  on c.IDArea = AA.IDArea  
	inner join App.tblCatUrls u with(nolock)  on u.IDController = c.IDController
	--inner join App.tblMenu m on a.IDAplicacion = m.IDAplicacion
	CROSS APPLY Seguridad.tblCatPerfiles perfil with(nolock) 
	CROSS APPLY Seguridad.tblUsuarios usuario with(nolock) 
	left join Seguridad.tblPermisosPerfilesControllers PermisoPerfil with(nolock)  on PermisoPerfil.IDController = c.IDController and PermisoPerfil.IDPerfil = perfil.IDPerfil
	left join Seguridad.tblPermisosUsuarioControllers puc with(nolock)  on puc.IDController = c.IDController and puc.IDUsuario = usuario.IDUsuario 
	WHERE usuario.IDPerfil = perfil.IDPerfil
GO
