USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [Evaluacion360].[spPDFEvaluacionEmpleadoNoGenerados] as  
	declare 
		@dtProyectos  Evaluacion360.dtProyectos  
		, @IDUsuario int
	;  

	SET LANGUAGE 'Spanish';

	if object_id('tempdb..#tempEmpsProyectos') is not null drop table #tempEmpsProyectos;
	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;

	select top 1 @IDUsuario =  cast(Valor as int) from app.tblConfiguracionesGenerales
	where IDConfiguracion = 'IDUsuarioAdmin'
  
	insert @dtProyectos  
	exec Evaluacion360.spBuscarProyectos @IDUsuario = @IDUsuario,@VerTodas=1
	
	--delete from @dtProyectos 
	--where IDEstatus <> 6 -- 6 = COMPLETO
  
	select distinct ep.IDEmpleadoProyecto--, ep.IDProyecto
	into #tempEmpsProyectos
	from [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) 
		inner join @dtProyectos p  on ep.IDProyecto = p.IDProyecto

	
	delete ep
	from #tempEmpsProyectos ep
		left join Evaluacion360.tblEvaluacionesEmpleados ee with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	where ee.IDEvaluacionEmpleado is null

	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEstatusEvaluacionEmpleado desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock) 
		join #tempEmpsProyectos ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock)  on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
	
	delete tep
	from #tempEmpsProyectos tep
		join #tempHistorialEstatusEvaluacion th on tep.IDEmpleadoProyecto = th.IDEmpleadoProyecto-- and th.IDEstatus <> 13 -- 13 = COMPLETA
	where tep.IDEmpleadoProyecto in (
		select tep.IDEmpleadoProyecto
		from #tempEmpsProyectos tep
			join #tempHistorialEstatusEvaluacion th on tep.IDEmpleadoProyecto = th.IDEmpleadoProyecto and isnull(th.IDEstatus,0) <> 13 and th.[ROW] = 1
	)

	select ep.*   
	from #tempEmpsProyectos p  
	 join Evaluacion360.tblEmpleadosProyectos ep on p.IDEmpleadoProyecto = ep.IDEmpleadoProyecto  
	where isnull(ep.PDFGenerado,cast(0 as bit)) = 0  

	select distinct IDProyecto
	from #tempEmpsProyectos p  
		join Evaluacion360.tblEmpleadosProyectos ep on p.IDEmpleadoProyecto = ep.IDEmpleadoProyecto  
	where isnull(ep.PDFGenerado,cast(0 as bit)) = 0
GO
