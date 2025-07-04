USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Seguridad].[fnBuscarUsuario]
(
	@IDUsuario int = 0
)
RETURNS TABLE 
AS
RETURN (
	Select 
	u.IDUsuario
	,isnull(u.IDEmpleado,0) as IDEmpleado
	,u.Cuenta
	,null as [Password]
	,isnull(u.IDPreferencia,0) as IDPreferencia
	,Nombre = case when e.IDEmpleado is not null then e.Nombre
				   else u.Nombre end
	,Apellido = case when e.IDEmpleado is not null then coalesce(e.Paterno,'')+' '+coalesce(e.Materno,'')
				   else u.Apellido end
	,u.Email
	,isnull(u.Activo,0) as Activo 
	,ISNULL(U.IDPerfil,0) as IDPerfil
	,P.Descripcion as Perfil
	,'' as URL
	,ROW_NUMBER()over(ORDER BY IDUsuario) as ROWNUMBER
	from Seguridad.tblUsuarios u 
		left join [RH].[tblEmpleados] e on u.IDEmpleado = e.IDEmpleado
		inner join Seguridad.tblCatPerfiles P
			on U.IDPerfil = P.IDPerfil
	Where (u.IDUsuario = @IDUsuario) OR (@IDUsuario = 0) 
 )
GO
