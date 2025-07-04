USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Reportes].[spReporteBasicoProgresoEvaluacion] (
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDusuario int
) as
	declare 
		@IDProyecto int
	;

	select @IDProyecto = cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDProyecto'),',')

	DECLARE @tempResponse AS TABLE (
		IDEmpleadoProyecto INT,
		IDProyecto INT,
		IDEmpleado INT,
		ClaveEmpleado VARCHAR(20),
		Colaborador VARCHAR(254),
		IDEvaluacionEmpleado INT,
		IDTipoRelacion INT,
		Relacion VARCHAR(100),
		IDEvaluador INT,
		ClaveEvaluador VARCHAR(20),
		Evaluador  VARCHAR(100),
		Minimo INT,
		Maximo INT,
		Requerido BIT,
		CumpleTipoRelacion BIT,
		[ROW] int,
		IDEstatusEvaluacionEmpleado int,
		IDEstatus int, 
		Estatus varchar(max),
		Progreso int,
		Iniciales varchar(10),
		Evaluar BIT
	);

	insert @tempResponse
	exec Evaluacion360.spBuscarEvaluacionesEmpleadosPorProyecto @IDProyecto=@IDProyecto,@IDUsuario=@IDUsuario

	select 
		r.ClaveEmpleado,
		r.Colaborador,

		empleado.Sucursal as [Sucursal Colaborador],
		empleado.Puesto as [Puesto Colaborador],
		empleado.Departamento as [Departamento Colaborador],
		empleado.Division as [Division Colaborador],

		r.Relacion,
		r.ClaveEvaluador,
		r.Evaluador,

		evaluador.Sucursal as [Sucursal Evaluador],
		evaluador.Puesto as [Puesto Evaluador],
		evaluador.Departamento as [Departamento Evaluador],
		evaluador.Division as [Division Evaluador],

		r.Estatus,
		r.Progreso
	from @tempResponse r
		join RH.tblEmpleadosMaster empleado on empleado.IDEmpleado = r.IDEmpleado
		join RH.tblEmpleadosMaster evaluador on evaluador.IDEmpleado = r.IDEvaluador

	where isnull(r.IDEvaluacionEmpleado, 0) != 0
	order by r.ClaveEmpleado
GO
