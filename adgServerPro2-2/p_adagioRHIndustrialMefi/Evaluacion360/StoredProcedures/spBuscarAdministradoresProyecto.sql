USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Evaluacion360].[spBuscarAdministradoresProyecto](
	@IDAdministradorProyecto int = 0
	,@IDProyecto			 int = 0
	,@IDUsuario				 int
) as
	select 
		ap.IDAdministradorProyecto
		,ap.IDProyecto
		,ap.IDUsuario
		,u.Cuenta
		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as NombreUsuario
		,isnull(ap.CreadoPorIDUsuario, 0) as CreadoPorIDUsuario
		,coalesce(uCr.Nombre, '')+' '+coalesce(uCr.Apellido, '') as CreadoPorUsuario
		,isnull(ap.FechaHoraReg, getdate()) as FechaHoraReg
		,SUBSTRING(coalesce(em.Nombre, ''), 1, 1)+SUBSTRING(coalesce(em.Paterno, coalesce(em.Materno, '')), 1, 1) as Iniciales
		,case when fe.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador  
	from Evaluacion360.tblAdministradoresProyecto ap
		left join Seguridad.tblUsuarios u on u.IDUsuario = ap.IDUsuario
		left join RH.tblEmpleadosMaster em on em.IDEmpleado = u.IDEmpleado
		left join Seguridad.tblUsuarios uCr on uCr.IDUsuario = ap.CreadoPorIDUsuario
		left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = u.IDEmpleado  
	where (ap.IDAdministradorProyecto = @IDAdministradorProyecto or ISNULL(@IDAdministradorProyecto, 0) = 0)		
		and (ap.IDProyecto = @IDProyecto or ISNULL(@IDProyecto, 0) = 0)
GO
