USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc Dashboard.spBuscarJefeEvaluacion(
	@IDProyecto int,
	@IDUsuario int
) as
	select distinct
		supervisor.IDEmpleado,
		supervisor.ClaveEmpleado,
		supervisor.NOMBRECOMPLETO as Jefe,
		supervisor.Departamento,
		supervisor.Sucursal,
		supervisor.Puesto,
		supervisor.Division
	from RH.tblJefesEmpleados je
		join RH.tblEmpleadosMaster supervisor on supervisor.IDEmpleado = je.IDJefe
		join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleado = je.IDEmpleado
			and ep.IDProyecto = @IDProyecto
	order by supervisor.ClaveEmpleado
GO
