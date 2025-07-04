USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar el estatus actual de una evaluación o de todas las evaluaciones de un proyecto
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-11-22
** Paremetros		:       

	NOTA: Si se modifica el result set de este SP será necesario modificar los siguiestes SP's:
		1 - [Evaluacion360].[spBorrarEvaluacionEmpleado]

	Se deberá ajustar la tabla temporal donde se guarda el resultado de este SP.
       
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarEstatusEvaluacionEmpleado](
		@IDProyecto int = 0
		,@IDEvaluacionEmpleado int = 0
)
 as
 DECLARE
  @IDIdioma VARCHAR(max);
       
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null
		drop table #tempHistorialEstatusEvaluacion;

	select  ee.IDEvaluacionEmpleado
		,ee.IDEmpleadoProyecto
		,ee.IDTipoRelacion
		,ee.IDEvaluador
		,ee.TotalPreguntas
		,ee.TotalPreguntasRespondidas
		,ee.Progreso
		,ee.IDTipoEvaluacion
		,ISNULL(eee.IDEstatusEvaluacionEmpleado,0) IDEstatusEvaluacionEmpleado
		,ISNULL(eee.IDEstatus,0) IDEstatus
		,ISNULL(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin Estatus') as Estatus
		,ISNULL(eee.IDUsuario,0) IDUsuario
		,ISNULL(eee.FechaCreacion,getdate()) as FechaCreacion
		,ROW_NUMBER()over(partition by ee.IDEvaluacionEmpleado 
							ORDER by ee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on eee.IDEstatus = estatus.IDEstatus
	where (ep.IDProyecto = @IDProyecto or @IDProyecto = 0) and (ee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado or @IDEvaluacionEmpleado = 0)
	
	select * 
	from #tempHistorialEstatusEvaluacion 
	where [ROW] = 1
GO
