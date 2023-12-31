USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Reportes].[spValidarRelacionesPruebas](
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)as 
	declare 
		@IDProyecto int
	;

	set @IDProyecto = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDProyecto'),','))

	if OBJECT_ID('tempdb..#tempResponse') is not null drop table #tempResponse;

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
		Evaluar BIT,
		TotalPages INT,
		TotalRows INT
	);

	insert @tempResponse
	exec [Evaluacion360].[spBuscarRelacionesProyecto]
		@IDEmpleado	  = 0
		,@IDEvaluador = 0
		,@IDProyecto  = @IDProyecto
		,@IDUsuario	  = @IDUsuario
	
	select distinct
		rProyecto.IDEmpleado,
		rProyecto.ClaveEmpleado		AS [CLAVE EMPLEADO],
		rProyecto.Colaborador		AS [COLABORADOR],
		rProyecto.IDEvaluador,
		rProyecto.ClaveEvaluador	AS [CLAVE EVALUADOR],
		rProyecto.Evaluador			AS [EVALUADOR],
		rProyecto.IDTipoRelacion,
		rProyecto.Relacion			AS [RELACIÓN]
	INTO #tempResponse
	from @tempResponse rProyecto
	where ISNULL(rProyecto.IDEvaluador, 0) <> 0
	order by rProyecto.ClaveEmpleado

	select
		r.[CLAVE EMPLEADO],
		r.[COLABORADOR],
		empleado.Puesto as [PUESTO COLABORADOR],
		empleado.Sucursal as [SUCURSAL COLABORADOR],
		r.[CLAVE EVALUADOR],
		r.[EVALUADOR],
		evaluador.Puesto as [PUESTO EVALUADOR],
		evaluador.Sucursal as [SUCURSAL EVALUADOR],
		r.[RELACIÓN],
		[RELACIÓN CORRECTO] = 
			case 
				/* Colega */ 
				when r.IDTipoRelacion = 3 and empleado.IDDivision = evaluador.IDDivision then 'SI'
				when r.IDTipoRelacion = 3 and empleado.IDDivision <> evaluador.IDDivision then 'NO'
			else 'SI' end,
		empleado.Division as [NIVEL EMPLEADO],
		evaluador.Division as [NIVEL EVALUADOR]
	from #tempResponse r
		join RH.tblEmpleadosMaster empleado on empleado.IDEmpleado = r.IDEmpleado
		join RH.tblEmpleadosMaster evaluador on evaluador.IDEmpleado = r.IDEvaluador
GO
