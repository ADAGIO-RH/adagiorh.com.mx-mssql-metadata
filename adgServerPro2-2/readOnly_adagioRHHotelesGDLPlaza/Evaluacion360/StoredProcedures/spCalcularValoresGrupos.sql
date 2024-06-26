USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

select * 
from Evaluacion360.tblEmpleadosProyectos ep
	join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	join RH.tblEmpleadosMaster e on ep.IDEmpleado = e.IDEmpleado
where ep.IDEmpleadoProyecto = 4984

*/
--select *
--from
----update 
--Evaluacion360.tblRespuestasPreguntas rp
--	join Evaluacion360.tblCatPreguntas p on rp.IDPregunta = p.IDPregunta
----set  Respuesta = 10
--where  p.Calificar = 0-- rp.Respuesta > 10

--IDEvaluacionEmpleado = 6078 and IDPregunta = 32879

--select *
--from Evaluacion360.tblPosiblesRespuestasPreguntas
--where IDPregunta = 32914
----[Evaluacion360].[spCalcularValoresGrupos] 64
--GO

--select *
--from Evaluacion360.tblCatGrupos g
--	join Evaluacion360.tblCatPreguntas p on g.IDGrupo = p.IDGrupo
--	left join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
--where p.IDTipoPregunta = 2 and g.TipoReferencia = 4-- g.IDGrupo =14165

--update rp
--set rp.Respuesta = 10
--from 
--Evaluacion360.tblCatGrupos g
--	join Evaluacion360.tblCatPreguntas p on g.IDGrupo = p.IDGrupo
--	left join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
--where p.IDTipoPregunta = 2 and g.TipoReferencia = 4-- g.IDGrupo =14165

CREATE PROC [Evaluacion360].[spCalcularValoresGrupos](
	@IDEvaluacionEmpleado int   --= 348 
	,@IDEstatusActualPrueba int --= 13
) as
	DECLARE 
			--@IDEvaluacionEmpleado int = 4
			--,@IDEstatusActualPrueba int = 11
			--,
			@IDEmpleadoProyecto int = 0
			,@IDProyecto int = 0
			,@IDGrupo int = 0
			,@IDPregunta int = 0
			,@MaxValorEscalaValoracionProyecto decimal(10,1) = 0.0
			,@MaxValorEscalaValoracionGrupo decimal(10,1) = 0.0
			,@MaxValorPreguntasOpcionMultiple decimal(10,1) = 0.0
			--,@TipoPreguntaEscala int = 8; /* 8: Escala proyecto | 9: Escala Grupo */
			;

	IF (@IDEstatusActualPrueba IS NULL)
	BEGIN
		SELECT @IDEstatusActualPrueba = Max(IDEstatus)
		FROM Evaluacion360.tblEstatusEvaluacionEmpleado with (nolock)
		WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado;
	END;

	SELECT @IDEmpleadoProyecto = tee.IDEmpleadoProyecto 
		 , @IDProyecto = tep.IDProyecto
	FROM Evaluacion360.tblEvaluacionesEmpleados tee with (nolock)
		JOIN Evaluacion360.tblEmpleadosProyectos tep with (nolock) ON tee.IDEmpleadoProyecto = tep.IDEmpleadoProyecto
	WHERE tee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado

	select @MaxValorEscalaValoracionProyecto = max(Valor)
	from [Evaluacion360].[tblEscalasValoracionesProyectos] with (nolock)
	where IDProyecto = @IDProyecto

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL		drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempEvaluacionesCompletas') is not null			drop table #tempEvaluacionesCompletas;
	if object_id('tempdb..#tempEstadisticos') is not null					drop table #tempEstadisticos;

	if object_id('tempdb..#tempGrupos') is not null							drop table #tempGrupos;
	if object_id('tempdb..#tempGruposFinal') is not null					drop table #tempGruposFinal;
	if object_id('tempdb..#tempPosiblesRespuestasPreguntas') is not null	drop table #tempPosiblesRespuestasPreguntas;

	CREATE TABLE #tempEstadisticos(
		IDGrupo int
		,IDTipoGrupo int 
		,TipoGrupo varchar(255)
		,TotalPreguntas  decimal(10,1)
		,MaximaCalificacionPosible		decimal(10,1)
		,CalificacionObtenida			decimal(10,1)
		,CalificacionMinimaObtenida		decimal(10,1)
		,CalificacionMaxinaObtenida		decimal(10,1)
		,Promedio as cast(CalificacionObtenida / TotalPreguntas  as decimal(10,1))  
		,Porcentaje as cast((CalificacionObtenida * 100) / (MaximaCalificacionPosible * TotalPreguntas)  as decimal(10,1)) 
	);

	--select g.IDGrupo,count(p.IDPregunta) as Total
	--from Evaluacion360.tblCatGrupos g
	--	join Evaluacion360.tblCatPreguntas p on g.IDGrupo = p.IDGrupo
	--where g.IDGrupo = 14156 and isnull(p.Calificar,0) = 1

	--select * from Evaluacion360.tblCatTiposPreguntasGrupos

	select cg.*, ctg.Nombre as TipoGrupo
	INTO #tempGrupos
	from Evaluacion360.tblCatGrupos cg with (nolock) 
		join [Evaluacion360].[tblCatTipoGrupo] ctg with (nolock) on cg.IDTipoGrupo = ctg.IDTipoGrupo
	where TipoReferencia = 4 and IDReferencia = @IDEvaluacionEmpleado

	select cg.IDGrupo, Max(prp.Valor) as Valor
	INTO #tempPosiblesRespuestasPreguntas
	from Evaluacion360.tblPosiblesRespuestasPreguntas prp with (nolock) 
		join Evaluacion360.tblCatPreguntas cp with (nolock)  on prp.IDPregunta = cp.IDPregunta
		join #tempGrupos cg on cp.IDGrupo = cg.IDGrupo
	where cg.IDTipoPreguntaGrupo = 1
	group by cg.IDGrupo

	select 
		cg.IDGrupo 
		,cg.IDTipoGrupo 
		,cg.TipoGrupo
		,cast(count(*) as decimal(10,1)) as TotalPreguntas
		--,count(*) * @MaxValorEscalaValoracion as MaximaCalificacionPosible
		,MaximaCalificacionPosible = 
			case when cg.IDTipoPreguntaGrupo = 2 then @MaxValorEscalaValoracionProyecto 
				 when cg.IDTipoPreguntaGrupo = 3 then (select max(Valor) 
														from Evaluacion360.tblEscalasValoracionesGrupos with (nolock) 
														where IDGrupo = cg.IDGrupo)
				 else 
					(select Max(Valor) 
					 from #tempPosiblesRespuestasPreguntas
					where IDGrupo = cg.IDGrupo )
				 end
		,SUM(cast(isnull(rp.ValorFinal,0) as decimal(10,1))) as CalificacionObtenida
		,min(cast(isnull(rp.ValorFinal,0) as decimal(10,1))) as CalificacionMinimaObtenida
		,max(cast(isnull(rp.ValorFinal,0) as decimal(10,1))) as CalificacionMaxinaObtenida
	INTO #tempGruposFinal
	from #tempGrupos cg
		join [Evaluacion360].[tblCatPreguntas] p with (nolock) on cg.IDGrupo = p.IDGrupo
		left join [Evaluacion360].[tblRespuestasPreguntas] rp with (nolock) on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
	where TipoReferencia = 4 and IDReferencia = @IDEvaluacionEmpleado and isnull(p.Calificar,0) = 1
	group BY cg.IDGrupo, cg.IDTipoGrupo ,cg.TipoGrupo,cg.IDTipoPreguntaGrupo

	update #tempGruposFinal
	set CalificacionMaxinaObtenida = CalificacionMaxinaObtenida / TotalPreguntas
	
	insert #tempEstadisticos
	select * from #tempGruposFinal
	
	--select * from #tempEstadisticos
	UPDATE cGrupo
	SET  cGrupo.TotalPreguntas				= te.TotalPreguntas
		,cGrupo.MaximaCalificacionPosible	= te.MaximaCalificacionPosible
		,cGrupo.CalificacionObtenida		= te.CalificacionObtenida
		,cGrupo.CalificacionMinimaObtenida	= te.CalificacionMinimaObtenida
		,cGrupo.CalificacionMaxinaObtenida	= te.CalificacionMaxinaObtenida
		,cGrupo.Promedio					= te.Promedio
		,cGrupo.Porcentaje					= te.Porcentaje
	from #tempEstadisticos te 
		JOIN Evaluacion360.tblCatGrupos cGrupo ON te.IDGrupo = cGrupo.IDGrupo

	--select * from #tempEstadisticos 


	--select * from Evaluacion360.tblPosiblesRespuestasPreguntas
GO
