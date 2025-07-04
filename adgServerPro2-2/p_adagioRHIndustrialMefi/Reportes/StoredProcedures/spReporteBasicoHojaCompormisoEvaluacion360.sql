USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoHojaCompormisoEvaluacion360] (
	@IDProyecto int
	,@IDEmpleadoProyecto int
	,@IDUsuario int
) as
	--declare 
	--	@IDProyecto int = 22
	--	,@IDEmpleadoProyecto int =  128
	--;

	select 
		ctg.Nombre as TipoGrupo
		, pa.Grupo
		, pa.CalificacionActual as Respuesta
		, e.NOMBRECOMPLETO
		, pa.Acciones
		, pa.ResultadoEsperado
		, format(isnull(pa.FechaCompromiso,getdate()),'dd/MM/yyyy') as FechaCompromiso
		, p.Nombre as Prueba
		, format(getdate(),'dd/MM/yyyy') as Fecha
		, ctg.Orden
	from Evaluacion360.tblPlanDeAccion pa				with (nolock) 
		join Evaluacion360.tblCatTipoGrupo ctg			with (nolock) on pa.IDTipoGrupo = ctg.IDTipoGrupo
		join Evaluacion360.tblEmpleadosProyectos ep		with (nolock) on ep.IDEmpleadoProyecto = pa.IDEmpleadoProyecto
		join Evaluacion360.tblCatProyectos p			with (nolock) on p.IDProyecto = ep.IDProyecto
		join RH.tblEmpleadosMaster e					with (nolock) on e.IDEmpleado = ep.IDEmpleado
	where pa.IDEmpleadoProyecto = @IDEmpleadoProyecto
	order by ctg.Orden, ctg.Nombre

	--if object_id('tempdb..#temp') is not null drop table #temp;

	--select  TipoGrupo
	--			,Grupo
	--			,cast(SUM(Respuesta)/count(*) as decimal(18,2))	as Respuesta
	--			,NOMBRECOMPLETO
	--			,Prueba
	--			,format(getdate(),'dd/MM/yyyy') as Fecha
	--			,Orden
	--into #temp
	--from (
	--	select 
	--		--g.IDGrupo
	--		--,g.IDTipoGrupo
	--		--,
	--		ctg.Nombre						as TipoGrupo
	--		,g.Nombre						as Grupo
	--		--,g.Descripcion					as DescripcionGrupo
	--		,cp.Descripcion					as Pregunta
	--		--,cp.Descripcion					as DescripcionPregunta
	--		,cast(SUM(rp.ValorFinal)/count(*) as decimal(18,2))	as Respuesta
	--		--,rp.ValorFinal
	--		,e.NOMBRECOMPLETO
	--		,p.Nombre as Prueba
	--		,ctg.Orden
	--	from Evaluacion360.tblEmpleadosProyectos ep with (nolock) 
	--		join Evaluacion360.tblEvaluacionesEmpleados ee with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	--		join RH.tblEmpleadosMaster e on e.IDEmpleado = ep.IDEmpleado
	--		join Evaluacion360.tblCatProyectos p with (nolock)  on p.IDProyecto = ep.IDProyecto
	--		join Evaluacion360.tblCatGrupos g with (nolock) on ee.IDEvaluacionEmpleado = g.IDReferencia and g.TipoReferencia = 4
	--		join Evaluacion360.tblCatTipoGrupo ctg with (nolock) on g.IDTipoGrupo = ctg.IDTipoGrupo
	--		join Evaluacion360.tblCatPreguntas cp with (nolock) on cp.IDGrupo = g.IDGrupo
	--		left join Evaluacion360.tblRespuestasPreguntas rp with (nolock) on cp.IDPregunta = rp.IDPregunta
	--	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto  
	--	group by ctg.Nombre,g.Nombre,cp.Descripcion,e.NOMBRECOMPLETO,p.Nombre,ctg.Orden
	--) CaliPreguntas
	--group by  TipoGrupo
	--		,Grupo
	--		,NOMBRECOMPLETO
	--		,Prueba
	--		,Orden

	--select *
	--from #temp
	--order by Orden, Grupo


	--order by g.IDTipoGrupo, g.Nombre,cp.Descripcion

	--delete eee
	--from Evaluacion360.tblEmpleadosProyectos ep
	--	join Evaluacion360.tblEvaluacionesEmpleados ee on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
	--	left join Evaluacion360.tblEstatusEvaluacionEmpleado eee on eee.IDEvaluacionEmpleado = ee.IDEvaluacionEmpleado
	--	left join Evaluacion360.tblCatEstatus ce on ce.IDEstatus = eee.IDEstatus
	--where ep.IDProyecto = @IDProyecto and ce.IDEstatus = 13
GO
