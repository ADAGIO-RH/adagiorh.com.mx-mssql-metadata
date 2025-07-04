USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[sp9BoxPorProyecto](
	@IDProyecto int = null
	,@IDEmpleadoProyecto int = null
)as

	--declare @IDProyecto int = 64

	--;
	SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END


	--select *
	--from Evaluacion360.tblCatProyectos
	--where IDProyecto = @IDProyecto
	if object_id('tempdb..#temp9BoxProyectos') is not null drop table #temp9BoxProyectos;
	if object_id('tempdb..#temp9BoxResultados') is not null drop table #temp9BoxResultados;

	create table #temp9BoxResultados(
		 IDEmpleadoProyecto int
		,box_13				varchar(50)
		,box_23				varchar(50)
		,box_33				varchar(50)
		,box_12				varchar(50)
		,box_22				varchar(50)
		,box_32				varchar(50)
		,box_11				varchar(50)
		,box_21				varchar(50)
		,box_31				varchar(50)
	);

	select
		ep.IDEmpleadoProyecto 
		,SUM(isnull(rp.Box9DesempenioActual,0)) / COUNT(*) as Box9DesempenioActual
		,sum(isnull(rp.Box9DesempenioFuturo,0)) /COUNT(*) as Box9DesempenioFuturo
		,cast('' as varchar(50)) ID
	--rp.*
	INTO #temp9BoxProyectos
	from Evaluacion360.tblEmpleadosProyectos ep
		join Evaluacion360.tblEvaluacionesEmpleados ee on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
		join Evaluacion360.tblCatGrupos g on g.IDReferencia = ee.IDEvaluacionEmpleado and g.TipoReferencia = 4
		join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
		join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
	where (ep.IDProyecto = @IDProyecto or @IDProyecto is null) and (ep.IDEmpleadoProyecto = @IDEmpleadoProyecto or @IDEmpleadoProyecto is null)
	--	and ep.IDEmpleado = @IDEmpleado 
		and p.Box9 = 1
	group by ep.IDEmpleadoProyecto


	update #temp9BoxProyectos
	set ID = 'box_'+cast(Box9DesempenioActual as varchar(2))+cast(Box9DesempenioFuturo as varchar(2))

	--select * from #temp9BoxProyectos

	select 
		 tp.IDEmpleadoProyecto 
		,em.NOMBRECOMPLETO NombreColaborador
		,box_13	= case when tp.ID = 'box_13' then '#f7f0d4' else '#eaf3e9' end			
		,box_23	= case when tp.ID = 'box_23' then '#cadac8' else '#eaf3e9' end			
		,box_33	= case when tp.ID = 'box_33' then '#cadac8' else '#eaf3e9' end			
		,box_12	= case when tp.ID = 'box_12' then '#f7d0a4' else '#eaf3e9' end			
		,box_22	= case when tp.ID = 'box_22' then '#f7f0d4' else '#eaf3e9' end			
		,box_32	= case when tp.ID = 'box_32' then '#cadac8' else '#eaf3e9' end			
		,box_11	= case when tp.ID = 'box_11' then '#f7d0a4' else '#eaf3e9' end			
		,box_21	= case when tp.ID = 'box_21' then '#f7d0a4' else '#eaf3e9' end			
		,box_31	= case when tp.ID = 'box_31' then '#f7f0d4' else '#eaf3e9' end		
		,d9box.Nombre as NombreBox9
		,d9box.Descripcion	
	from #temp9BoxProyectos tp
		join Evaluacion360.tblEmpleadosProyectos ep on tp.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join Evaluacion360.tblDescripciones9Box d9box on tp.ID = d9box.ID
		join RH.tblEmpleadosMaster em on ep.IDEmpleado = em.IDEmpleado



--		select * from Evaluacion360.tblDescripciones9Box
 


	--id="box_13" style="background-color:#f7f0d4"
	--id="box_23" style="background-color:#cadac8"
	--id="box_33" style="background-color:#cadac8"
	--id="box_12" style="background-color:#f7d0a4"
	--id="box_22" style="background-color:#f7f0d4"
	--id="box_32" style="background-color:#cadac8"
	--id="box_11" style="background-color:#f7d0a4"
	--id="box_21" style="background-color:#f7d0a4"
	--id="box_31" style="background-color:#f7f0d4"
GO
