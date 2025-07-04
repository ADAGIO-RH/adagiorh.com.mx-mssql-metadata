USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca todos los colaboradores que han sido evaluados por rangos de fechas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-07-18
** Paremetros		:              

** DataTypes Relacionados: 


[Evaluacion360].[spBuscarTodosLosEmpleadosEvaluadosRangoFecha] @FechaInicio = '2018-01-01'
 ,@FechaFin = '2019-12-31'
 	,@IDUsuario = 1 

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarTodosLosEmpleadosEvaluadosRangoFecha](
	@FechaInicio date
	,@FechaFin date
	,@IDUsuario int
) as

declare @dtProyectos [Evaluacion360].[dtProyectos];
--declare @FechaInicio date = '2018-01-01'
--		,@FechaFin date = '2019-12-31'
--		,@IDUsuario int = 1 ;


	SET LANGUAGE 'Spanish';

	if object_id('tempdb..#tempEmpsProyectos') is not null drop table #tempEmpsProyectos;
	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempFinal') is not null drop table #tempFinal;
	if object_id('tempdb..#tempFinal2') is not null drop table #tempFinal2;


	insert @dtProyectos
	exec [evaluacion360].[spBuscarProyectos] @IDUsuario = @IDUsuario

	delete @dtProyectos where IDEstatus <> 6

	select distinct ep.IDEmpleadoProyecto, ep.IDEmpleado
	into #tempEmpsProyectos
	from [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) 
		inner join @dtProyectos p  on ep.IDProyecto = p.IDProyecto
		--inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = ep.IDEmpleado and dfe.IDUsuario = @IDUsuario
	where p.FechaInicio between @FechaInicio and @FechaFin

	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock) 
		join #tempEmpsProyectos ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock)  on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
	
	-- select * from Evaluacion360.tblCatEstatus
	
	delete from #tempHistorialEstatusEvaluacion where [ROW] > 1

	delete tep
	from #tempEmpsProyectos tep
		join #tempHistorialEstatusEvaluacion th on tep.IDEmpleadoProyecto = th.IDEmpleadoProyecto and th.IDEstatus <> 13 

	select 
		ep.IDEmpleado
		,ep.IDEmpleadoProyecto
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO
		,em.Departamento
		,em.Sucursal
		,em.Puesto
		,epp.IDProyecto
		,isnull(epp.PDFGenerado,0) as PDFGenerado
		,isnull(epp.TotalGeneral	 ,0) as TotalGeneral
		,isnull(epp.TotalCompetencias,0) as TotalCompetencias
		,isnull(epp.TotalKPIs		 ,0) as TotalKPIs
		,isnull(epp.TotalValores,0) as TotalValores
		,epp.TipoFiltro
		,isnull(cl.Literal,'D') as Literal
	INTO #tempFinal
	from #tempEmpsProyectos ep
		left join Evaluacion360.tblEmpleadosProyectos epp  with (nolock) on epp.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [RH].[tblEmpleadosMaster] em with (nolock)  on ep.IDEmpleado = em.IDEmpleado
		left join Evaluacion360.tblCatCalificacionesLiterales cl with (nolock)  on epp.TotalGeneral between cl.CalificacionInicial and cl.CalificacionFinal
	--where (ep.IDProyecto = @IDProyecto or @IDProyecto is null) and (ep.IDEmpleadoProyecto = @IDEmpleadoProyecto or @IDEmpleadoProyecto is null)

	--if (isnull(@IDProyecto,0) = 0)
	--begin
	--	;WITH tempCTE (IDEmpleado,duplicateRecCount)
	--	AS
	--	(
	--	SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDEmpleado ORDER BY IDEmpleado) AS duplicateRecCount
	--	FROM #tempFinal
	--	)
	--	--Now Delete Duplicate Rows
	--	DELETE FROM tempCTE
	--	WHERE duplicateRecCount > 1 
	--end;

	select IDEmpleado,ClaveEmpleado,NOMBRECOMPLETO,Departamento,Puesto,SUM(TotalGeneral) / COUNT(TotalGeneral) as TotalGeneral ,COUNT(*) as TotalPruebas
	INTO #tempFinal2
	from #tempFinal 
	group by IDEmpleado,ClaveEmpleado,NOMBRECOMPLETO,Departamento,Puesto

	select #tempFinal2.*,isnull(cl.Literal,'D') as Literal
	from #tempFinal2
	left join Evaluacion360.tblCatCalificacionesLiterales cl with (nolock) on floor(isnull(TotalGeneral,0)) between cl.CalificacionInicial and cl.CalificacionFinal
	order by NOMBRECOMPLETO


	--select * from Evaluacion360.tblCatCalificacionesLiterales
GO
