USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca todos los colaboradores que han sido evaluados
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2022-10-30
** Paremetros		:              

** DataTypes Relacionados: 

[Evaluacion360].[spBuscarTodosLosEvaluados]39,1
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarTodosLosEvaluados](
	@IDProyecto int
	,@IDUsuario int
) as

	declare 
		@IDEmpleadoJefe int
	;
	SET LANGUAGE 'Spanish';

	select @IDEmpleadoJefe = IDEmpleado
	from Seguridad.tblUsuarios
	where IDUsuario = @IDUsuario

	if object_id('tempdb..#tempEmpsProyectos') is not null drop table #tempEmpsProyectos;
	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempFinal') is not null drop table #tempFinal;

	select distinct ep.IDEmpleadoProyecto, ep.IDEmpleado
	into #tempEmpsProyectos
	from [Evaluacion360].[tblEmpleadosProyectos] ep
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = ep.IDEmpleado and dfe.IDUsuario = @IDUsuario
	where IDProyecto = @IDProyecto
		and (
			(ep.IDEmpleado in (select IDEmpleado from RH.tblJefesEmpleados where IDJefe = @IDEmpleadoJefe) or @IDUsuario in (select IDUsuario from Evaluacion360.tblAdministradoresProyecto where IDProyecto = @IDProyecto))
		)
		AND ep.TipoFiltro <> 'Excluir Empleado'
	--or isnull(@IDProyecto,0) = 0

	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee
		join #tempEmpsProyectos ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
	
	-- select * from Evaluacion360.tblCatEstatus
	
	delete from #tempHistorialEstatusEvaluacion where [ROW] > 1

	--delete tep
	--from #tempEmpsProyectos tep
	--	join #tempHistorialEstatusEvaluacion th on tep.IDEmpleadoProyecto = th.IDEmpleadoProyecto and th.IDEstatus <> 13 

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
		,SUBSTRING(coalesce(em.Nombre, ''), 1, 1)+SUBSTRING(coalesce(em.Paterno, coalesce(em.Materno, '')), 1, 1) as Iniciales
		,case when fe.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador  
	INTO #tempFinal
	from #tempEmpsProyectos ep
		left join Evaluacion360.tblEmpleadosProyectos epp on epp.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [RH].[tblEmpleadosMaster] em on ep.IDEmpleado = em.IDEmpleado
		left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = em.IDEmpleado  
		left join Evaluacion360.tblCatCalificacionesLiterales cl on floor(isnull(epp.TotalGeneral,0)) between cl.CalificacionInicial and cl.CalificacionFinal
	--where (ep.IDProyecto = @IDProyecto or @IDProyecto is null) and (ep.IDEmpleadoProyecto = @IDEmpleadoProyecto or @IDEmpleadoProyecto is null)

	if (isnull(@IDProyecto,0) = 0)
	begin
		;WITH tempCTE (IDEmpleado,duplicateRecCount)
		AS
		(
		SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDEmpleado ORDER BY IDEmpleado) AS duplicateRecCount
		FROM #tempFinal
		)
		--Now Delete Duplicate Rows
		DELETE FROM tempCTE
		WHERE duplicateRecCount > 1 
	end;

	select * from #tempFinal order by NOMBRECOMPLETO
GO
