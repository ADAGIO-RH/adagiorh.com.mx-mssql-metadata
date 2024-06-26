USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBuscarAplicacionPerfiles](
	@IDPerfil int,
	@IDUsuario int
) as
select 
	isnull(ap.IDAplicacionPerfil,0) as IDAplicacionPerfil
	,ca.IDAplicacion
	,ca.Descripcion as DescripcionAplicacion
	,Permiso = case when ap.IDAplicacionPerfil is not null then cast(1 as bit) else cast(0 as bit) end
	,@IDPerfil as IDPerfil
from [App].[tblAplicacionPerfiles] ap
	right join [App].[tblCatAplicaciones] ca on ap.IDAplicacion = ca.IDAplicacion and ap.IDPerfil = @IDPerfil
order by ca.Orden asc
GO
