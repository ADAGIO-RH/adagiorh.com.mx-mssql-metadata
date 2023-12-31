USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
						  
CREATE proc [Evaluacion360].[spBuscarParticipantesDeEmpleadoProyecto] (
	@IDEmpleadoProyecto int
) as
    SET NOCOUNT ON;
    IF 1=0 
	BEGIN
		SET FMTONLY OFF
    END

	declare @TotalPorRelacion as table (
		IDEvaluador int,
		IDTipoRelacion int,
		Relacion varchar(255),
		Porcentaje decimal(10, 1),
		Promedio decimal(10, 1)
	 )

	insert @TotalPorRelacion
	exec [Evaluacion360].[spCalificacionFinalEmpleadoProyectoPorEvaluador] @IDEmpleadoProyecto=@IDEmpleadoProyecto

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempEstatusEvaluacion') is not null drop table #tempEstatusEvaluacion;

	select * 
	INTO #tempEstatusEvaluacion
	from Evaluacion360.tblCatEstatus 
	where IDTipoEstatus  = 2

	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,estatus.Estatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ep.IDProyecto
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock) on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
		left join #tempEstatusEvaluacion estatus on eee.IDEstatus = estatus.IDEstatus
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto

	select 
		em.*
		,evaluador.ClaveEmpleado
		,evaluador.NOMBRECOMPLETO
		,SUBSTRING (evaluador.Nombre, 1, 1) + SUBSTRING (evaluador.Paterno, 1, 1) AS Iniciales
		,CASE WHEN fe.IDEmpleado IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS ExisteFotoColaborador
		,ctp.Relacion
		,estatus.Estatus
		,isnull(total.Porcentaje, CAST(0 as decimal(10,1))) as Porcentaje
		,isnull(total.Promedio, CAST(0 as decimal(10,1))) as Promedio
	from [Evaluacion360].[tblEvaluacionesEmpleados] em
		join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		join [RH].[tblEmpleadosMaster] evaluador on evaluador.IDEmpleado = em.IDEvaluador
		left join @TotalPorRelacion total on total.IDEvaluador = em.IDEvaluador
		left join #tempHistorialEstatusEvaluacion estatus on estatus.IDEvaluacionEmpleado = em.IDEvaluacionEmpleado and estatus.[ROW] = 1
		left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = evaluador.IDEmpleado
	where em.IDEmpleadoProyecto = @IDEmpleadoProyecto
GO
