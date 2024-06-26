USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarEvaluacionEmpleado](
	@IDEvaluacionEmpleado int 
) as

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END
--declare @IDEvaluacionEmpleado int = 105657

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null
		drop table #tempHistorialEstatusEvaluacion;

 
	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,estatus.Estatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock) on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on eee.IDEstatus = estatus.IDEstatus
	where ee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado 

	--select * from #tempHistorialEstatusEvaluacion
	select 
		 ee.IDEvaluacionEmpleado
		,ee.IDEmpleadoProyecto
		,ee.IDTipoRelacion
		,ee.IDEvaluador
		,evaluador.NOMBRECOMPLETO as NombreEvaluador
		,evaluador.Puesto as PuestoEvaluador
		,ep.IDProyecto
		,ep.IDEmpleado
		,empleado.NOMBRECOMPLETO as NombreColaborador
		,empleado.Puesto as PuestoColaborador
		,estatus.IDEstatusEvaluacionEmpleado
		,estatus.IDEstatus
		,estatus.Estatus
		,estatus.IDUsuario
		,estatus.FechaCreacion 
		--,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
		--					ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join #tempHistorialEstatusEvaluacion estatus on ee.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.[ROW]  = 1
		left join [RH].[tblEmpleadosMaster] empleado with (nolock) on ep.IDEmpleado = empleado.IDEmpleado
		left join [RH].[tblEmpleadosMaster] evaluador with (nolock) on ee.IDEvaluador = evaluador.IDEmpleado
	where ee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado 

--	select * from #tempHistorialEstatusEvaluacion


--select *
--from [Evaluacion360].[tblEvaluacionesEmpleados]
--where IDEvaluacionEmpleado = @IDEvaluacionEmpleado
GO
