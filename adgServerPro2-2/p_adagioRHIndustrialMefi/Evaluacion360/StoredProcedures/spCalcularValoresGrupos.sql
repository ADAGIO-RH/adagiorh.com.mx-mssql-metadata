USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Calcula los totales de un grupo de una prueba
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-10-28			Aneudy Abreu		Se agrega validación para que no se consideren las preguntas
										con un valor final de respuesta -1 en los promedios
***************************************************************************************************/
CREATE   PROC [Evaluacion360].[spCalcularValoresGrupos](
	@IDEvaluacionEmpleado int   = null 
	,@IDEstatusActualPrueba int = null
) as
	DECLARE 
		@IDEmpleadoProyecto int = 0
		,@IDProyecto int = 0
		,@IDGrupo int = 0
		,@IDPregunta int = 0
		,@MaxValorEscalaValoracionProyecto decimal(10,1) = 0.0
		,@MaxValorEscalaValoracionGrupo decimal(10,1) = 0.0
		,@MaxValorPreguntasOpcionMultiple decimal(10,1) = 0.0
		--,@TipoPreguntaEscala int = 8; /* 8: Escala proyecto | 9: Escala Grupo */
		,@ID_TIPO_PREGUNTA_GRUPO_MIXTA int = 1
		,@ID_TIPO_PREGUNTA_GRUPO_ESCALA_PRUEBA int = 2
		,@ID_TIPO_PREGUNTA_GRUPO_ESCALA_INDIVIDUAL int = 3
		,@ID_TIPO_PREGUNTA_GRUPO_FUNCION_CLAVE int = 5
		,@SI int = 1
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
		,Promedio decimal(10,1) --as cast(CalificacionObtenida / TotalPreguntas  as decimal(10,1))  
		,Porcentaje decimal(10,1) --as cast((CalificacionObtenida * 100) / (MaximaCalificacionPosible * TotalPreguntas)  as decimal(10,1))
	);

	select cg.*, ctg.Nombre as TipoGrupo
	INTO #tempGrupos
	from Evaluacion360.tblCatGrupos cg with (nolock) 
		join [Evaluacion360].[tblCatTipoGrupo] ctg with (nolock) on cg.IDTipoGrupo = ctg.IDTipoGrupo
	where TipoReferencia = 4 and IDReferencia = @IDEvaluacionEmpleado
	--SELECT * FROM #tempGrupos
	
	
	


	-- OLD
	--select cg.IDGrupo, Max(prp.Valor) as Valor
	--INTO #tempPosiblesRespuestasPreguntas
	--from Evaluacion360.tblPosiblesRespuestasPreguntas prp with (nolock) 
	--	join Evaluacion360.tblCatPreguntas cp with (nolock)  on prp.IDPregunta = cp.IDPregunta
	--	join #tempGrupos cg on cp.IDGrupo = cg.IDGrupo
	--where cg.IDTipoPreguntaGrupo = 1
	--group by cg.IDGrupo
	
	-- NEW
	SELECT Sub.IDGrupo, ISNULL(SUM(Sub.Valor), 0) AS Valor
	INTO #tempPosiblesRespuestasPreguntas
	FROM ( 
	select cg.IDGrupo
			, prp.IDPregunta				
			, CASE
				WHEN cp.IDTipoPregunta = 2
					THEN (SELECT SUM(Valor) FROM Evaluacion360.tblPosiblesRespuestasPreguntas prp2 WHERE prp2.IDPregunta = prp.IDPregunta)
				ELSE
					(SELECT MAX(Valor) FROM Evaluacion360.tblPosiblesRespuestasPreguntas prp2 WHERE prp2.IDPregunta = prp.IDPregunta)
				END AS Valor
	from Evaluacion360.tblPosiblesRespuestasPreguntas prp with (nolock) 
		join Evaluacion360.tblCatPreguntas cp with (nolock)  on prp.IDPregunta = cp.IDPregunta
		join #tempGrupos cg on cp.IDGrupo = cg.IDGrupo
	where cg.IDTipoPreguntaGrupo = 1 AND Calificar = 1
	GROUP BY cg.IDGrupo, prp.IDPregunta, cp.IDTipoPregunta
	) Sub
	GROUP BY Sub.IDGrupo
	


	

	select 
		cg.IDGrupo 
		,cg.IDTipoGrupo 
		,cg.TipoGrupo
		,cast(count(*) as decimal(10,1)) as TotalPreguntas
		--,count(*) * @MaxValorEscalaValoracion as MaximaCalificacionPosible
		,MaximaCalificacionPosible = 
			case when cg.IDTipoPreguntaGrupo IN (@ID_TIPO_PREGUNTA_GRUPO_ESCALA_PRUEBA, @ID_TIPO_PREGUNTA_GRUPO_FUNCION_CLAVE) then @MaxValorEscalaValoracionProyecto 
				 when cg.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_ESCALA_INDIVIDUAL then (select max(Valor) 
														from Evaluacion360.tblEscalasValoracionesGrupos with (nolock) 
														where IDGrupo = cg.IDGrupo)
				 else 
					(select Max(Valor) 
					 from #tempPosiblesRespuestasPreguntas
					where IDGrupo = cg.IDGrupo )
				 end
		,SUM(cast(isnull(rp.ValorFinal,0.00) as decimal(10,2))) as CalificacionObtenida		
		,min(cast(isnull(rp.ValorFinal,0.00) as decimal(10,2))) as CalificacionMinimaObtenida
		,max(cast(isnull(rp.ValorFinal,0.00) as decimal(10,2))) as CalificacionMaxinaObtenida
		,CalcularDiferente = 
			case when cg.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
				then 1
				else 0
			end
	INTO #tempGruposFinal
	from #tempGrupos cg
		join [Evaluacion360].[tblCatPreguntas] p with (nolock) on cg.IDGrupo = p.IDGrupo
		left join [Evaluacion360].[tblRespuestasPreguntas] rp with (nolock) on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
	where TipoReferencia = 4 and IDReferencia = @IDEvaluacionEmpleado and isnull(p.Calificar,0) = 1 and isnull(rp.ValorFinal, 0) != -1
	group BY cg.IDGrupo, cg.IDTipoGrupo ,cg.TipoGrupo,cg.IDTipoPreguntaGrupo	
	--SELECT * FROM #tempGruposFinal


	update #tempGruposFinal
		set CalificacionMaxinaObtenida = CalificacionMaxinaObtenida / TotalPreguntas
	where isnull(CalificacionMaxinaObtenida, 0) > 0


	insert #tempEstadisticos
	select IDGrupo
			, IDTipoGrupo
			, TipoGrupo
			, TotalPreguntas
			, MaximaCalificacionPosible
			, CalificacionObtenida
			, CalificacionMinimaObtenida
			, CalificacionMaxinaObtenida
			, Promedio = cast(CalificacionObtenida / TotalPreguntas  as decimal(10,1))  
			, Porcentaje = CASE 
				WHEN CalcularDiferente = @SI
					THEN cast((CalificacionObtenida / MaximaCalificacionPosible) * 100 as decimal(10,1)) 
					ELSE cast((CalificacionObtenida * 100) / (MaximaCalificacionPosible * TotalPreguntas)  as decimal(10,1))
				END			
	from #tempGruposFinal
	--where isnull(CalificacionMaxinaObtenida, 0) > 0
	

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
GO
