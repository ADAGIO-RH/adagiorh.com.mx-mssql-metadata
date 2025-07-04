USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar las evaluaciones pendientes de un Evaluador
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-15
** Paremetros		:              

** DataTypes Relacionados: 

-- Si se modifica este SP será necesario modificar los siguientes:
	 [Evaluacion360].[spCrearNotificacionEvaluacionEmpleado]

	 ********************************************************************
	 **																   **
	 **							DEPRECATED							   **
	 **																   **
	 ********************************************************************
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
/*
[Evaluacion360].[spBuscarPruebasPendientesDeRealizar]  
					 @IDUsuario   = 1
					,@IDEvaluador   = 460

					*/
CREATE proc [Evaluacion360].[spBuscarPruebasPendientesDeRealizar] (
 --   @IDProyecto int 
	--,
	@IDEvaluador int 
	,@IDUsuario int  
) as
 DECLARE
 @IDIdioma VARCHAR(max);
        
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	if object_id('tempdb..#tempHistorialEstatusProyectos') is not NULL
			drop table #tempHistorialEstatusProyectos;
	

	select 
	tep.IDEstatusProyecto
	,tep.IDProyecto
	,isnull(tep.IDEstatus,0) AS IDEstatus
	,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') AS Estatus
	,tep.IDUsuario
	,tep.FechaCreacion 
	,ROW_NUMBER()over(partition by tep.IDProyecto 
						ORDER by tep.IDProyecto, tep.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusProyectos
	from [Evaluacion360].[tblCatProyectos] tcp with (nolock)
		left join [Evaluacion360].[tblEstatusProyectos] tep	 with (nolock) on tep.IDProyecto = tcp.IDProyecto --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null
		drop table #tempHistorialEstatusEvaluacion;

	-- select * from [Evaluacion360].[tblEmpleadosProyectos] where IDProyecto = @IDProyecto
	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
	--where ep.IDProyecto = @IDProyecto 

	select
		 ee.IDEvaluacionEmpleado
		,ee.IDEmpleadoProyecto
		,ee.IDTipoRelacion
		,JSON_VALUE(cte.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
		,ee.IDEvaluador
		,eva.ClaveEmpleado as ClaveEvaluador
		,eva.NOMBRECOMPLETO as Evaluador
		,ep.IDProyecto
		,p.Nombre as Proyecto
		,ep.IDEmpleado
		,emp.ClaveEmpleado 
		,emp.NOMBRECOMPLETO as Colaborador
		,thee.IDEstatusEvaluacionEmpleado
		,thee.IDEstatus
		,JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) as Estatus
		,thee.IDUsuario
		,thee.FechaCreacion		
		,isnull(ee.Progreso,0) as Progreso-- = case when isnull(thee.IDEstatus,0) != 0 then floor(RAND()*(100-0)+0) else 0 end
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee 
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join #tempHistorialEstatusEvaluacion thee on ee.IDEvaluacionEmpleado = thee.IDEvaluacionEmpleado and thee.[ROW]  = 1
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on thee.IDEstatus = estatus.IDEstatus
		join [Evaluacion360].[tblCatTiposRelaciones] cte on ee.IDTipoRelacion = cte.IDTipoRelacion
		left join [RH].[tblEmpleadosMaster] emp on ep.IDEmpleado = emp.IDEmpleado
		left join [RH].[tblEmpleadosMaster] eva on ee.IDEvaluador = eva.IDEmpleado
		join [Evaluacion360].[tblCatProyectos] p on ep.IDProyecto = p.IDProyecto
		join #tempHistorialEstatusProyectos estatusProyectos on estatusProyectos.IDProyecto = p.IDProyecto
	where /* ep.IDProyecto = @IDProyecto and */  ee.IDEvaluador = @IDEvaluador
		and thee.IDEstatus in (11,12) /*11	-	E_Evaluador asignado
										12	-	E_En proceso*/
		and estatusProyectos.IDEstatus = 3
GO
