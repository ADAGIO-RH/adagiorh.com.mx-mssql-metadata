USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Seguridad].[spBuscarEmpleadosQueNoTienenUsuario]  
as  
	declare @IDPerfilDefaultEmpleados int = null;  
  
	select @IDPerfilDefaultEmpleados = case when TipoValor = 'int' then cast(Valor as int) else null end  
	from App.tblConfiguracionesGenerales  
	where IDConfiguracion = 'IDPerfilDefaultEmpleados'  
  
  
	select 
		isnull(u.IDUsuario,0) as IDUsuario
		,e.IDEmpleado
		,e.ClaveEmpleado
		,e.Nombre
		,e.Paterno
		,e.Vigente as Activo
		,@IDPerfilDefaultEmpleados as IDPerfil  
		,e.FechaNacimiento
		,e.RFC
		,null Email
	from RH.tblEmpleadosMaster e  
		left join Seguridad.tblUsuarios u on e.IDEmpleado = u.IDEmpleado   
		left join [Utilerias].[fnBuscarCorreosEmpleados](null) email on email.IDEmpleado = e.IDEmpleado
	where e.Vigente = 1 --and u.IDEmpleado is not null  
	and u.IDEmpleado is null  
  
  
--select *  
--from rh.tblEmpleadosMaster
GO
