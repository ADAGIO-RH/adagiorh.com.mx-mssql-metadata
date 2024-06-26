USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spBuscarCalificacionesGruposPorProyecto] (
	@IDProyecto int
	,@IDUsuario int
) as
--declare @IDProyecto int =4
--	,@IDUsuario int = 1
--	;
	
	SET FMTONLY OFF;

	--select * from Evaluacion360.tblCatProyectos

	declare @RelacionesProyecto table(
		IDEmpleadoProyecto	   int
		,IDProyecto			   int
		,IDEmpleado			   int
		,Colaborador		   varchar(500)
		,IDEvaluacionEmpleado  int
		,IDTipoRelacion		   int
		,Relacion			   varchar(100)
		,IDEvaluador		   int
		,Evaluador			   varchar(500)
		,Requerido 			   bit
	);

	--select ep.IDEmpleado,ee.*
	--from Evaluacion360.tblEmpleadosProyectos ep
	--	join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	--where ep.IDProyecto = @IDProyecto

	if object_id('tempdb..#tempCalificacionesColaboradores') is not null drop table #tempCalificacionesColaboradores;
	if object_id('tempdb..#tempCalificacionesMAX') is not null drop table #tempCalificacionesMAX;
	if object_id('tempdb..#tempCalificacionesMIN') is not null drop table #tempCalificacionesMIN;
	if object_id('tempdb..#tempCalificacionesFinal') is not null drop table #tempCalificacionesFinal;

	insert @RelacionesProyecto
	exec [Evaluacion360].[spBuscarRelacionesProyecto]  
	 @IDProyecto =@IDProyecto 
	,@IDUsuario =@IDUsuario

	select rp.IDEmpleado,rp.Colaborador,cg.Nombre as Grupo, cast( sum(cg.Porcentaje) / count(*) as decimal(10,2)) as Porcentaje,cast('NINGUNO' as varchar(100)) as ColaboradorMaximaCalificacion,cast('NINGUNO' as varchar(100)) ColaboradorMinimaCalificacion
	INTO #tempCalificacionesColaboradores
	from @RelacionesProyecto rp
		join Evaluacion360.tblCatGrupos cg on cg.TipoReferencia = 4 and cg.IDReferencia = rp.IDEvaluacionEmpleado
	group by rp.IDEmpleado,rp.Colaborador,cg.Nombre	


	select *,ROW_NUMBER()OVER(partition by Grupo order by Grupo,Porcentaje desc) as Maximo
	INTO #tempCalificacionesMAX
	from #tempCalificacionesColaboradores t
	order by Grupo,Porcentaje desc

	select *,Minimo = ROW_NUMBER()OVER(partition by Grupo order by Grupo,Porcentaje asc) 
	INTO #tempCalificacionesMIN
	from #tempCalificacionesColaboradores t
	order by Grupo,Porcentaje desc

	delete from #tempCalificacionesMAX where Maximo <> 1
	delete from #tempCalificacionesMIN where Minimo <> 1

	--select * from #tempCalificacionesMAX  
	--select * from #tempCalificacionesMIN  

	--delete Maximos
	--from #tempCalificacionesMAX Maximos
	-- left join #tempCalificacionesMIN Minimos on Maximos.IDEmpleado = Minimos.IDEmpleado and Maximos.Grupo = Minimos.Grupo
	--where Minimos.IDEmpleado is not null

	delete Minimos 
	from #tempCalificacionesMAX Maximos
	 left join #tempCalificacionesMIN Minimos on Maximos.IDEmpleado = Minimos.IDEmpleado and Maximos.Grupo = Minimos.Grupo
	where Maximos.IDEmpleado is not null


	--update tcc
	--set ColaboradorMaximaCalificacion = tcm.Colaborador
	--from #tempCalificacionesColaboradores tcc
	--	join #tempCalificacionesMAX tcm on tcc.IDEmpleado = tcm.IDEmpleado and tcc.Grupo = tcm.Grupo

	--update tcc
	--set ColaboradorMinimaCalificacion = tcm.Colaborador
	--from #tempCalificacionesColaboradores tcc
	--	join #tempCalificacionesMIN tcm on tcc.IDEmpleado = tcm.IDEmpleado and tcc.Grupo = tcm.Grupo
 
	--select *
	--from #tempCalificacionesColaboradores

	select cg.Nombre as Grupo, cast( sum(cg.Porcentaje) / count(*) as decimal(10,2)) as Porcentaje,isnull( tcMax.Colaborador,'NINGUN@' ) as CalificacionMaxima,isnull(tcMin.Colaborador,'NINGUN@') as CalificacionMinima
	INTO #tempCalificacionesFinal
	from @RelacionesProyecto rp
		join Evaluacion360.tblCatGrupos cg on cg.TipoReferencia = 4 and cg.IDReferencia = rp.IDEvaluacionEmpleado
		left join #tempCalificacionesMAX tcMax on cg.Nombre = tcMax.Grupo
		left join #tempCalificacionesMIN tcMin on cg.Nombre = tcMin.Grupo
		-- left join #tempCalificacionesColaboradores tc on tc.Grupo = cg.Nombre
	group by cg.Nombre,tcMax.Colaborador,tcMin.Colaborador

	select cf.*,isnull(cl.Literal,'D') as Literal
	from #tempCalificacionesFinal cf
		left join Evaluacion360.tblCatCalificacionesLiterales cl on floor(isnull(cf.Porcentaje,0)) between cl.CalificacionInicial and cl.CalificacionFinal
	order by cf.Porcentaje desc
GO
