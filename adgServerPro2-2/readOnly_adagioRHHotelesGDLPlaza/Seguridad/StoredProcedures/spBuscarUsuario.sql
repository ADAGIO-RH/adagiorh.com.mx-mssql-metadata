USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los usuarios registrados en la base de datos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2017-12-31
** Paremetros		:              

** DataTypes Relacionados: 
	[Seguridad].[dtUsuarios]

	Si se modifica el result set de este sp será necesario modificar los siguientes sp:
		[App].[INotificacionActivarCuenta]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-13		Aneudy Abreu		Se agregó el campo de Sexo a la tabla de usuarios los campos
									Nombre, Apellido y Sexo se toman de la tabla de Usuarios y ya
									no de la tabla de empleados
***************************************************************************************************/
CREATE PROCEDURE [Seguridad].[spBuscarUsuario]
(
	@IDUsuario int = 0
)
AS
BEGIN
	Select 
	u.IDUsuario
	,isnull(u.IDEmpleado,0) as IDEmpleado
	,coalesce(e.ClaveEmpleado,'') as ClaveEmpleado
	,u.Cuenta
	,null as [Password]
	,isnull(u.IDPreferencia,0) as IDPreferencia
	,u.Nombre
	,u.Apellido
	,coalesce(u.Sexo,'') as Sexo
	--,Nombre = case when e.IDEmpleado is not null then e.Nombre
	--			   else u.Nombre end
	--,Apellido = case when e.IDEmpleado is not null then coalesce(e.Paterno,'')+' '+coalesce(e.Materno,'')
	--			   else u.Apellido end
	--,Sexo = case when e.IDEmpleado is not null then e.Sexo else '' end
	,u.Email
	,isnull(u.Activo,0) as Activo 
	,ISNULL(U.IDPerfil,0) as IDPerfil
	,P.Descripcion as Perfil
	,'' as [URL]
	,isnull(u.Supervisor,0) as Supervisor 
	,ROW_NUMBER()over(ORDER BY IDUsuario) as ROWNUMBER
	from Seguridad.tblUsuarios u with (nolock) 
		left join [RH].[tblEmpleados] e with (nolock) on u.IDEmpleado = e.IDEmpleado
		inner join Seguridad.tblCatPerfiles P with (nolock)
			on U.IDPerfil = P.IDPerfil
	Where (u.IDUsuario = @IDUsuario) OR (@IDUsuario = 0) 
END
GO
