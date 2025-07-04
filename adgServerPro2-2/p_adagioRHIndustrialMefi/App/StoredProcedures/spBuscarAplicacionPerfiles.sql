USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[App].[spBuscarAplicacionPerfiles] 9,3911
--------------------Cambios----------------------------------------------------------------------------------------------------------------
-- Julio Castillo 09/11/2023
-- Se le agrego el parametro PermisoUsuarioLogin y consulta a la vista para saber si tiene permiso en los modulos por perfil o por usuario

CREATE proc [App].[spBuscarAplicacionPerfiles](
	@IDPerfil int,
	@IDUsuario int
) as
select 
	isnull(ap.IDAplicacionPerfil,0) as IDAplicacionPerfil
	,ca.IDAplicacion
	,ca.Descripcion as DescripcionAplicacion
	,Permiso = case when isnull(ap.IDAplicacionPerfil,0) <> 0 then cast(1 as bit) else cast(0 as bit) end
	,@IDPerfil as IDPerfil
    ,PermisoUsuarioLogin = case when isnull(vapu.Permiso,0) = 1 then cast(1 as bit) else cast(0 as bit) end 
     
from [App].[tblCatAplicaciones] ca
	left join [App].[tblAplicacionPerfiles] ap on ap.IDAplicacion = ca.IDAplicacion and ap.IDPerfil = @IDPerfil
    left join Seguridad.vwAplicacionesUsuarios vapu on vapu.IDAplicacion = ca.IDAplicacion and vapu.IDUsuario = @IDUsuario
order by ca.Orden asc
GO
