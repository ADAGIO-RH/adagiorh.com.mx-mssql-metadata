USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW Seguridad.vwPermisosUsuariosController
AS
select
	
	a.IDAplicacion    
	,areas.IDArea    
	,areas.Descripcion as Area    
	,c.IDController    
	,c.Nombre as Controller
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
	,IDTipoPermiso = CASE WHEN isnull(puc.PermisoPersonalizado,0) = 1 THEN puc.IDTipoPermiso else PermisoPerfil.IDTipoPermiso end
	,PermisosEspeciales =  case when exists (select top 1 1    
			from App.tblCatControllers cc    
			join App.tblCatUrls ur on cc.IDController = ur.IDController and ur.Tipo = 'V'    
			and cc.IDController= c.IDController
			join App.tblCatPermisosEspeciales pe on ur.IDUrl = pe.IDUrlParent    
			) then cast(1 as bit) else cast(0 as bit) end
	,m.Orden	       
from App.tblCatAplicaciones a 
	inner join App.tblMenu m on a.IDAplicacion = m.IDAplicacion
	inner join App.tblCatUrls u on u.IDUrl = m.IDUrl   
	inner join App.tblCatControllers c on c.IDController = u.IDController  
	left join App.tblCatAreas areas on c.IDArea = areas.IDArea 
	left join Seguridad.tblPermisosPerfilesControllers PermisoPerfil on PermisoPerfil.IDController = c.IDController
	left join Seguridad.tblCatPerfiles perfil on perfil.IDPerfil = PermisoPerfil.IDPerfil
	left join Seguridad.tblUsuarios usuario on usuario.IDPerfil = perfil.IDPerfil
	left join Seguridad.tblPermisosUsuarioControllers puc on puc.IDController = PermisoPerfil.IDController and puc.IDUsuario = usuario.IDUsuario
GO
