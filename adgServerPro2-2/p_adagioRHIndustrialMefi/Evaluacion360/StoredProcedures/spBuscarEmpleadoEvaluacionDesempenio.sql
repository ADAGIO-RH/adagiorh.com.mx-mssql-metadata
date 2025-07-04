USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Evaluacion360.spBuscarEmpleadoEvaluacionDesempenio(
	@IDEmpleadoProyecto int,
	@IDUsuario int
) as
	declare
		@IDProyecto int,
		@FechaIni date,
		@FechaFin date,
		@ClaveEmpleadoInicial varchar(20),
		@ClaveEmpleadoFinal varchar(20),
		@dtEmpleados [RH].[dtEmpleados]
	;

	declare @tblTempResultados as table (
		 IDEmpleadoProyecto	int	
		,IDTipoEvaluacion	int		
		,TipoEvaluacion		varchar(max)
		,Progreso	decimal(18, 2)				
		,Promedio	decimal(18, 2)				
		,Porcentaje	decimal(18, 2)
	);

	insert @tblTempResultados
	exec [Evaluacion360].[spBuscarTiposEvaluacionesEmpleadoProyecto]
		@IDEmpleadoProyecto = @IDEmpleadoProyecto,
		@IDUsuario = @IDUsuario

	select 
		@ClaveEmpleadoInicial = e.ClaveEmpleado,
		@ClaveEmpleadoFinal = e.ClaveEmpleado,
		@FechaIni = p.FechaInicio,
		@FechaFin = p.FechaFin
	from Evaluacion360.tblEmpleadosProyectos ep
		join RH.tblEmpleados e on e.IDEmpleado = ep.IDEmpleado
		join Evaluacion360.tblCatProyectos p on p.IDProyecto = ep.IDProyecto
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto

	insert into @dtEmpleados
	Exec [RH].[spBuscarEmpleados] 
		@EmpleadoIni=@ClaveEmpleadoInicial,
		@EmpleadoFin=@ClaveEmpleadoFinal,
		@FechaIni = @FechaIni, 
		@FechaFin = @FechaFin,
		@IDUsuario=@IDUsuario

	select 
		e.ClaveEmpleado,
		e.NOMBRECOMPLETO as Colaborador,
		e.Departamento,
		e.Sucursal,
		e.Puesto,
		(
			select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO 
			from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock) on je.IDJefe = emp.IDEmpleado
			where je.IDEmpleado = e.IDEmpleado and isnull(emp.Vigente, 0) = 1
			order by je.IDJefeEmpleado desc
		) as Supervisor,
		cast((select sum(Promedio)/count(*) from @tblTempResultados)	as decimal(18, 2)) as TotalGeneralPromedio,
		cast((select sum(Porcentaje)/count(*) from @tblTempResultados)	as decimal(18, 2)) as TotalGeneralPorcentaje
	from @dtEmpleados e
GO
