USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROC [Evaluacion360].[spCalcularValoresGrupos_2](
	@IDEvaluacionEmpleado int 
		,@IDEstatusActualPrueba int = null
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

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempEvaluacionesCompletas') is not null drop table #tempEvaluacionesCompletas;
	if object_id('tempdb..#tempEstadisticos') is not null drop table #tempEstadisticos;

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

	-- Mixta
	if exists (SELECT TOP 1 1
				FROM Evaluacion360.tblCatGrupos tcg	with (nolock)
				WHERE tcg.TipoReferencia = 4 AND tcg.IDReferencia = @IDEvaluacionEmpleado AND tcg.IDTipoPreguntaGrupo = 1
				)
	BEGIN
		print 'Mixta'
		if object_id('tempdb..#tempGruposMixtas') is not null
			drop table #tempGruposMixtas;		
	
		SELECT
			cg.*
			,tctg.Nombre AS TipoGrupo
			--,cast(0 as bit) GrupoEscala
		INTO #tempGruposMixtas
		from [Evaluacion360].[tblCatGrupos] cg with (nolock)
			JOIN [Evaluacion360].[tblCatTipoGrupo] tctg with (nolock)	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
		where (cg.TipoReferencia = 4 and cg.IDReferencia = @IDEvaluacionEmpleado 
					AND cg.IDTipoPreguntaGrupo = 1)
 

		select '#tempGruposMixtas',* from #tempGruposMixtas
		SELECT @IDGrupo = min(IDGrupo) FROM #tempGruposMixtas tg

		WHILE EXISTS(SELECT TOP 1 1 FROM #tempGruposMixtas tg WHERE IDGrupo >= @IDGrupo)
		BEGIN
			if object_id('tempdb..#tempPreguntasGruposMixtas') is not null drop table #tempPreguntasGruposMixtas;

			select *
			INTO #tempPreguntasGruposMixtas
			from [Evaluacion360].[tblCatPreguntas] with (nolock)
			where IDGrupo = @IDGrupo and Calificar = 1 --IDTipoPregunta = 1 /* Solo preguntas de tipo Opción multiples*/

			SELECT @IDPregunta = min(IDPregunta) FROM #tempPreguntasGruposMixtas 
			while exists(select top 1 1 from #tempPreguntasGruposMixtas where IDPregunta >= @IDPregunta)
			begin
				--select @MaxValorPreguntasOpcionMultiple = max(isnull(cast(Valor as decimal(10,1)),0))
				--from [Evaluacion360].[tblPosiblesRespuestasPreguntas]  with (nolock)
				--where IDPregunta = @IDPregunta and isnull(Valor,0) > 0

				--Print '@IDPregunta: '+cast(@IDPregunta as varchar(100))
				--Print '@MaxValorPreguntasOpcionMultiple: '+cast(@MaxValorPreguntasOpcionMultiple as varchar(100))

				--if (@MaxValorPreguntasOpcionMultiple > 0)
				--begin
				INSERT #tempEstadisticos
				SELECT
					cg.IDGrupo 
					,cg.IDTipoGrupo 
					,ctg.Nombre as TipoGrupo
					,cast(count(*) as decimal(10,1)) as TotalPreguntas
					--,count(*) * @MaxValorEscalaValoracion as MaximaCalificacionPosible
					,max(p.MaximaCalificacionPosible) as MaximaCalificacionPosible
					,SUM(cast(isnull(rp.Respuesta,0) as decimal(10,1))) / count(*) as CalificacionObtenida
					,min(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionMinimaObtenida
					,max(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionMaxinaObtenida
				from #tempPreguntasGruposMixtas p with (nolock)
					join [Evaluacion360].[tblCatGrupos] cg with (nolock) on cg.IDGrupo = p.IDGrupo
					join [Evaluacion360].[tblCatTipoGrupo] ctg with (nolock) on cg.IDTipoGrupo = ctg.IDTipoGrupo
					--join [Evaluacion360].[tblQuienResponderaPregunta] qrp on qrp.IDPregunta = p.IDPregunta and (cg.IDTipoRelacion = case when qrp.IDTipoRelacion = 5 then cg.IDTipoRelacion else qrp.IDTipoRelacion end) /*Revisar esta parte, se deben de quitar las preguntas de la prueba al generar dicha prueba segun el tipo de relación*/
					left join [Evaluacion360].[tblRespuestasPreguntas] rp with (nolock) on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
					left join [Evaluacion360].[tblCatCategoriasPreguntas] cp with (nolock) on p.IDCategoriaPregunta = cp.IDCategoriaPregunta
				where (cg.IDGrupo = @IDGrupo and p.IDPregunta = @IDPregunta) -- and p.Descripcion = @Pregunta
				group BY cg.IDGrupo, cg.IDTipoGrupo ,ctg.Nombre 		
			--	end;
				SELECT @IDPregunta = min(IDPregunta) FROM #tempPreguntasGruposMixtas  where IDPregunta > @IDPregunta
			end;

			SELECT @IDGrupo = min(IDGrupo) FROM #tempGruposMixtas tg WHERE IDGrupo > @IDGrupo
		END;
	END;
	--	select * from #tempEstadisticos
	-- Escala del Proyecto
	if exists (SELECT TOP 1 1
				FROM Evaluacion360.tblCatGrupos tcg	with (nolock)
				WHERE tcg.TipoReferencia = 4 AND tcg.IDReferencia = @IDEvaluacionEmpleado 
					AND tcg.IDTipoPreguntaGrupo = 2)
	BEGIN
		print 'Escala del proyecto'
		if object_id('tempdb..#tempGrupos') is not null
			drop table #tempGrupos;

		select @MaxValorEscalaValoracionProyecto = max(Valor)
		from [Evaluacion360].[tblEscalasValoracionesProyectos] with (nolock)
		where IDProyecto = @IDProyecto

		--select ee.*
		--	,eee.IDEstatusEvaluacionEmpleado
		--	,eee.IDEstatus
		--	,estatus.Estatus
		--	,eee.IDUsuario
		--	,eee.FechaCreacion 
		--,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
		--					ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
		--INTO #tempHistorialEstatusEvaluacion
		--from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		--	join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		--	left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock) on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
		--	left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on eee.IDEstatus = estatus.IDEstatus
		--where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto 

		--select ep.IDEmpleadoProyecto, em.IDEvaluacionEmpleado,em.IDTipoRelacion,ctp.Relacion
		--INTO #tempEvaluacionesCompletas
		--from [Evaluacion360].[tblEvaluacionesEmpleados] em
		--	join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on em.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		--	join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		--	left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
		--where em.IDEmpleadoProyecto = @IDEmpleadoProyecto
			-- and estatus.IDEstatus = 13 /*Estatus COMPLETA*/

		SELECT
			cg.*
			,tctg.Nombre AS TipoGrupo
			,GrupoEscala = case when exists (select top 1 1 
											from [Evaluacion360].[tblCatPreguntas] with (nolock)
											where IDGrupo = cg.IDGrupo and (IDTipoPregunta = 8) /*Escala Proyecto*/)
								then cast(1 as bit) else cast(0 as bit) end
		INTO #tempGrupos
		from [Evaluacion360].[tblCatGrupos] cg with (nolock)
			JOIN [Evaluacion360].[tblCatTipoGrupo] tctg with (nolock)	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
		where (cg.TipoReferencia = 4 and cg.IDReferencia = @IDEvaluacionEmpleado 
					AND cg.IDTipoPreguntaGrupo = 2)
 
		INSERT #tempEstadisticos
		SELECT
			 cg.IDGrupo 
			,cg.IDTipoGrupo 
			,cg.TipoGrupo
			,cast(count(*) as decimal(10,1)) as TotalPreguntas
			--,count(*) * @MaxValorEscalaValoracion as MaximaCalificacionPosible
			, @MaxValorEscalaValoracionProyecto as MaximaCalificacionPosible
			,SUM(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionObtenida
			,min(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionMinimaObtenida
			,max(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionMaxinaObtenida
		from #tempGrupos cg
			join [Evaluacion360].[tblCatTipoGrupo] ctg with (nolock) on cg.IDTipoGrupo = ctg.IDTipoGrupo
			join [Evaluacion360].[tblCatPreguntas] p with (nolock) on cg.IDGrupo = p.IDGrupo
			--join [Evaluacion360].[tblQuienResponderaPregunta] qrp on qrp.IDPregunta = p.IDPregunta and (cg.IDTipoRelacion = case when qrp.IDTipoRelacion = 5 then cg.IDTipoRelacion else qrp.IDTipoRelacion end) /*Revisar esta parte, se deben de quitar las preguntas de la prueba al generar dicha prueba segun el tipo de relación*/
			left join [Evaluacion360].[tblRespuestasPreguntas] rp with (nolock) on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
			left join [Evaluacion360].[tblCatCategoriasPreguntas] cp with (nolock) on p.IDCategoriaPregunta = cp.IDCategoriaPregunta
		--where (cg.GrupoEscala = 1 )-- and p.Descripcion = @Pregunta
		group BY cg.IDGrupo, cg.IDTipoGrupo ,cg.TipoGrupo 		

	END;
	-- Escala Individual
	if exists (SELECT TOP 1 1
				FROM Evaluacion360.tblCatGrupos tcg	with (nolock)
				WHERE tcg.TipoReferencia = 4 AND tcg.IDReferencia = @IDEvaluacionEmpleado 
					AND tcg.IDTipoPreguntaGrupo = 3)
	BEGIN
		print 'Escala individual'
		if object_id('tempdb..#tempGrupos3') is not null
			drop table #tempGrupos3;		

		--select ee.*
		--	,eee.IDEstatusEvaluacionEmpleado
		--	,eee.IDEstatus
		--	,estatus.Estatus
		--	,eee.IDUsuario
		--	,eee.FechaCreacion 
		--,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
		--					ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
		--INTO #tempHistorialEstatusEvaluacion
		--from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		--	join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		--	left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock) on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
		--	left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on eee.IDEstatus = estatus.IDEstatus
		--where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto 

		--select ep.IDEmpleadoProyecto, em.IDEvaluacionEmpleado,em.IDTipoRelacion,ctp.Relacion
		--INTO #tempEvaluacionesCompletas
		--from [Evaluacion360].[tblEvaluacionesEmpleados] em
		--	join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on em.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		--	join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		--	left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
		--where em.IDEmpleadoProyecto = @IDEmpleadoProyecto
			-- and estatus.IDEstatus = 13 /*Estatus COMPLETA*/

		SELECT
			cg.*
			,tctg.Nombre AS TipoGrupo
			--,GrupoEscala = case when exists (select top 1 1 
			--								from [Evaluacion360].[tblCatPreguntas] with (nolock)
			--								where IDGrupo = cg.IDGrupo and (IDTipoPregunta = 8) /*Escala Proyecto*/)
			--					then cast(1 as bit) else cast(0 as bit) end
		INTO #tempGrupos3
		from [Evaluacion360].[tblCatGrupos] cg with (nolock)
			JOIN [Evaluacion360].[tblCatTipoGrupo] tctg with (nolock)	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
		where (cg.TipoReferencia = 4 and cg.IDReferencia = @IDEvaluacionEmpleado 
					AND cg.IDTipoPreguntaGrupo = 3)
 
		SELECT @IDGrupo = min(IDGrupo)
		FROM #tempGrupos3 tg

		WHILE EXISTS(SELECT TOP 1 1 FROM #tempGrupos3 tg WHERE IDGrupo >= @IDGrupo)
		BEGIN
			select @MaxValorEscalaValoracionGrupo = max(Valor)
			from [Evaluacion360].[tblEscalasValoracionesGrupos] tevg with (nolock)
			where tevg.IDGrupo = @IDGrupo

			INSERT #tempEstadisticos
			SELECT
				 cg.IDGrupo 
				,cg.IDTipoGrupo 
				,cg.TipoGrupo
				,cast(count(*) as decimal(10,1)) as TotalPreguntas
				--,count(*) * @MaxValorEscalaValoracion as MaximaCalificacionPosible
				, @MaxValorEscalaValoracionGrupo as MaximaCalificacionPosible
				,SUM(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionObtenida
				,min(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionMinimaObtenida
				,max(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionMaxinaObtenida
			from #tempGrupos3 cg with (nolock)
				join [Evaluacion360].[tblCatTipoGrupo] ctg with (nolock) on cg.IDTipoGrupo = ctg.IDTipoGrupo
				join [Evaluacion360].[tblCatPreguntas] p with (nolock) on cg.IDGrupo = p.IDGrupo
				--join [Evaluacion360].[tblQuienResponderaPregunta] qrp on qrp.IDPregunta = p.IDPregunta and (cg.IDTipoRelacion = case when qrp.IDTipoRelacion = 5 then cg.IDTipoRelacion else qrp.IDTipoRelacion end) /*Revisar esta parte, se deben de quitar las preguntas de la prueba al generar dicha prueba segun el tipo de relación*/
				left join [Evaluacion360].[tblRespuestasPreguntas] rp with (nolock) on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
				left join [Evaluacion360].[tblCatCategoriasPreguntas] cp with (nolock) on p.IDCategoriaPregunta = cp.IDCategoriaPregunta
			where (cg.IDGrupo = @IDGrupo) -- and p.Descripcion = @Pregunta
			group BY cg.IDGrupo, cg.IDTipoGrupo ,cg.TipoGrupo 		

			SELECT @IDGrupo = min(IDGrupo) FROM #tempGrupos3 tg WHERE IDGrupo > @IDGrupo
		END;
	END;


	if object_id('tempdb..#tempEstadisticosFinal') is not null
			drop table #tempEstadisticosFinal;

	select * from #tempEstadisticos
	select	
		te.IDGrupo
		,cast(sum(te.TotalPreguntas)				as decimal(10,1))	  as TotalPreguntas
		,cast(max(te.MaximaCalificacionPosible)		as decimal(10,1))  as MaximaCalificacionPosible
		,cast(sum(te.CalificacionObtenida)/count(*)	as decimal(10,1))  as CalificacionObtenida
		,cast(min(te.CalificacionMinimaObtenida)	as decimal(10,1))	  as CalificacionMinimaObtenida
		,cast(max(te.CalificacionMaxinaObtenida)	as decimal(10,1))	  as CalificacionMaxinaObtenida
		,cast(sum(te.Promedio)/count(*)				as decimal(10,1))  as Promedio
		,cast(sum(te.Porcentaje)/count(*)			as decimal(10,1))  as Porcentaje
	INTO #tempEstadisticosFinal
	from #tempEstadisticos te
	group by IDGrupo
	
	--select * from #tempEstadisticosFinal
	--,Porcentaje as cast((CalificacionObtenida * 100) / (MaximaCalificacionPosible * TotalPreguntas)  as decimal(10,1)) 
--		select  cast((18.0 * 100) / (3.0 * 3.0)  as decimal(10,1)) 

	UPDATE cGrupo
	SET  cGrupo.TotalPreguntas				= te.TotalPreguntas
		,cGrupo.MaximaCalificacionPosible	= te.MaximaCalificacionPosible
		,cGrupo.CalificacionObtenida		= te.CalificacionObtenida
		,cGrupo.CalificacionMinimaObtenida	= te.CalificacionMinimaObtenida
		,cGrupo.CalificacionMaxinaObtenida	= te.CalificacionMaxinaObtenida
		,cGrupo.Promedio					= te.Promedio
		,cGrupo.Porcentaje					= te.Porcentaje
	from #tempEstadisticosFinal te 
		JOIN Evaluacion360.tblCatGrupos cGrupo ON te.IDGrupo = cGrupo.IDGrupo

	--SELECT * FROM #tempEstadisticos

	--SELECT @IDEstatusActualPrueba AS IDEstatusActualPrueba, @IDEmpleadoProyecto AS IDEmpleadoProyecto, @IDProyecto AS IDProyecto

	--SELECT * FROM Evaluacion360.tblCatTiposPreguntasGrupos tctpg

	--SELECT *
	--FROM Evaluacion360.tblCatEstatus tce
	--	JOIN Evaluacion360.tblCatTiposEstatus tcte ON tce.IDTipoEstatus = tcte.IDTipoEstatus
	--WHERE tce.IDTipoEstatus = 2






--SELECT *
--FROM Evaluacion360.tblEvaluacionesEmpleados tee
--	JOIN Evaluacion360.tblEmpleadosProyectos tep ON tee.IDEmpleadoProyecto = tep.IDEmpleadoProyecto
--WHERE tep.IDProyecto = 36

--SELECT * FROM Evaluacion360.tblCatGrupos tcg

--ALTER TABLE Evaluacion360.tblCatGrupos
--	ADD TotalPreguntas  decimal(10,1)
--ALTER TABLE Evaluacion360.tblCatGrupos
--	ADD MaximaCalificacionPosible  decimal(10,1)
--ALTER TABLE Evaluacion360.tblCatGrupos
--	ADD CalificacionObtenida decimal(10,1)
--ALTER TABLE Evaluacion360.tblCatGrupos
--	ADD CalificacionMinimaObtenida	  decimal(10,1)
--ALTER TABLE Evaluacion360.tblCatGrupos
--	ADD CalificacionMaxinaObtenida	  decimal(10,1)

--ALTER TABLE Evaluacion360.tblCatGrupos
--	ADD Promedio decimal(10,2)

--ALTER TABLE Evaluacion360.tblCatGrupos
--	ADD Porcentaje decimal(10,2)
GO
