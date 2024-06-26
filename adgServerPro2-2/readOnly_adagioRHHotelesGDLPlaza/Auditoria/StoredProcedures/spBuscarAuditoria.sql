USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Auditoria.spBuscarAuditoria(
	@IDUsuario int = 0
	,@IDEmpleado int = 0
	,@FechaIni date = '2020-01-01'
	,@FechaFin date = '2020-07-01'
	,@IDUsuarioLogin int = 1
) as
	--declare 
	--	@IDUsuario int = 0
	--	,@IDEmpleado int = 0
	--	,@FechaIni date = '2020-01-01'
	--	,@FechaFin date = '2020-07-01'
	--	,@IDUsuarioLogin int = 1
	--;

	select 
		 a.IDAuditoria
		,a.IDUsuario
		,u.Cuenta as CuentaUsuario
		,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as NombreUsuario
		,u.IDPerfil
		,p.Descripcion as Perfil
		,u.Email as EmailUsuario
		,a.Fecha
		,a.Tabla
		,a.Procedimiento
		,a.Accion
		,a.NewData
		,a.OldData
		,isnull(a.IDEmpleado,0) as IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,a.Mensaje
		,a.InformacionExtra
	from Auditoria.tblAuditoria a with (nolock)
		join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = a.IDUsuario
		join Seguridad.tblCatPerfiles p with (nolock) on p.IDPerfil = u.IDPerfil
		left join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = a.IDEmpleado
	where (a.IDUsuario = @IDUsuario or @IDUsuario = 0)
		and (a.IDEmpleado = @IDEmpleado or @IDEmpleado = 0)
		and cast(a.Fecha as date) between @FechaIni and @FechaFin
GO
