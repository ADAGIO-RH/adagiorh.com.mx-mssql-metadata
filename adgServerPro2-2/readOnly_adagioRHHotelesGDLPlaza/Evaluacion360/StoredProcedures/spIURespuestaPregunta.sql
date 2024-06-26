USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [Evaluacion360].[spIURespuestaPregunta](
	@dtRespuestas [Evaluacion360].[dtRespuestaPregunta] READONLY
	,@IDUsuario int )
as
	DECLARE @IDEvaluacionEmpleado int = 0
			,@IDEstatusActualPrueba int = 0
			,@IDProyecto int = 0
	;

	IF object_id('tempdb..#tmpPreguntasPruebas') IS NOT NULL DROP TABLE #tmpPreguntasPruebas;
	IF object_id('tempdb..#tmpRespuestasCalificadas') IS NOT NULL DROP TABLE #tmpRespuestasCalificadas;

	select p.*, ValorFinal =  case 
							when isnull(cp.Calificar,0) = 1 then 
									case 
										when cp.IDTipoPregunta = 1 then p.Respuesta		-- OPCIÓN MÚLTIPLE
										when cp.IDTipoPregunta = 2 then					-- CASILLAS DE VERIFICACIÓN (Promedio de posibles respuestas)
											(select sum(prp.Valor)/count(*) 
											 from App.Split(p.Respuesta,',') as posiblesRespuestas
												join Evaluacion360.tblPosiblesRespuestasPreguntas prp on cast(posiblesRespuestas.item as int) = prp.IDPosibleRespuesta 
											 )
										when cp.IDTipoPregunta in (3,4,6,7) then 0			-- 3 VALORACIÓN CON ESTRELLAS - 4 CUADRO DE TEXTO SIMPLE - 6 - CONTROL DESLIZANTE (No requiere nunca Calificación numérica) - 7 FECHA/HORA
										when cp.IDTipoPregunta = 5 then 					-- MENÚ DESPLEGABLE
											(select top 1 prp.Valor
											 from App.Split(p.Respuesta,',') as posiblesRespuestas
												join Evaluacion360.tblPosiblesRespuestasPreguntas prp on cast(posiblesRespuestas.item as int) = prp.IDPosibleRespuesta 
											 )
										when cp.IDTipoPregunta in (8,9) then p.Respuesta	-- ESCALA PROYECTO - ESCALA INDIVIDUAL
									else 0 end
						else 0.0 end
	INTO #tmpRespuestasCalificadas
	from @dtRespuestas p
		join Evaluacion360.tblCatPreguntas cp on p.IDPregunta = cp.IDPregunta
	where isnull(p.Box9,'') = '' and Respuesta is not null
	
	--select *
	--INTO #tmpRespuestasCalificadas
	--from @dtRespuestas

	SELECT TOP 1 @IDEvaluacionEmpleado = [@dtRespuestas].IDEvaluacionEmpleado from @dtRespuestas;

	SELECT @IDProyecto = tep.IDProyecto
	FROM [Evaluacion360].[tblEvaluacionesEmpleados] tee with (nolock)
		JOIN Evaluacion360.tblEmpleadosProyectos tep with (nolock) ON tee.IDEmpleadoProyecto = tep.IDEmpleadoProyecto
	WHERE tee.IDEvaluacionEmpleado = @IDEvaluacionEmpleado

	SELECT @IDEstatusActualPrueba = Max(IDEstatus)
	FROM Evaluacion360.tblEstatusEvaluacionEmpleado with (nolock)
	WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado;
	
	MERGE [Evaluacion360].[tblRespuestasPreguntas] AS TARGET
	USING (select *
			from #tmpRespuestasCalificadas
			where isnull(Box9,'') = '' and Respuesta is not null
			) as SOURCE
	on TARGET.IDEvaluacionEmpleado = SOURCE.IDEvaluacionEmpleado
		and TARGET.IDPregunta = SOURCE.IDPregunta 
	WHEN MATCHED THEN
		update 
			set TARGET.Respuesta			= SOURCE.Respuesta
				,TARGET.ValorFinal			= SOURCE.ValorFinal 
				,TARGET.FechaHoraRespuesta	= getdate()
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(IDEvaluacionEmpleado,IDPregunta,Respuesta,ValorFinal,FechaHoraRespuesta)
		values(SOURCE.IDEvaluacionEmpleado,SOURCE.IDPregunta,SOURCE.Respuesta,SOURCE.ValorFinal,getdate())
	;

	MERGE [Evaluacion360].[tblRespuestasPreguntas] AS TARGET
	USING (select *
			from @dtRespuestas
			where isnull(Box9,'') = 'actual'  and Respuesta is not null
			) as SOURCE
	on TARGET.IDEvaluacionEmpleado = SOURCE.IDEvaluacionEmpleado
			and TARGET.IDPregunta = SOURCE.IDPregunta
	WHEN MATCHED THEN
		update 
			set TARGET.Box9DesempenioActual = cast(SOURCE.Respuesta as int)
	--WHEN NOT MATCHED BY TARGET THEN 
	--	INSERT(IDEvaluacionEmpleado,IDPregunta,Respuesta,FechaHoraRespuesta)
	--	values(SOURCE.IDEvaluacionEmpleado,SOURCE.IDPregunta,SOURCE.Respuesta,getdate())
	;

	MERGE [Evaluacion360].[tblRespuestasPreguntas] AS TARGET
	USING  (select *
			from @dtRespuestas
			where isnull(Box9,'') = 'futuro'  and Respuesta is not null
			) as SOURCE
	on TARGET.IDEvaluacionEmpleado = SOURCE.IDEvaluacionEmpleado
		and TARGET.IDPregunta = SOURCE.IDPregunta
	WHEN MATCHED THEN
		update 
			set TARGET.Box9DesempenioFuturo = cast(SOURCE.Respuesta as int)
	--WHEN NOT MATCHED BY TARGET THEN 
	--	INSERT(IDEvaluacionEmpleado,IDPregunta,Respuesta,FechaHoraRespuesta)
	--	values(SOURCE.IDEvaluacionEmpleado,SOURCE.IDPregunta,SOURCE.Respuesta,getdate())
	;

	SELECT tcp.Descripcion 
		,tcp.IDPregunta
		,tcp.EsRequerida
		,tcp.Box9
		,tcp.Calificar
		,trp.IDRespuestaPregunta
		,trp.Box9DesempenioActual
		,trp.Box9DesempenioFuturo
		,trp.Respuesta
		,trp.ValorFinal
		,Completa = CASE 
			WHEN isnull(tcp.EsRequerida,0) = 0 and tcp.Vista = 1 THEN 1
			WHEN 
				(isnull(tcp.EsRequerida,0) = 1) 
				AND (isnull(tcp.Box9EsRequerido,0) = 1) 
				AND (isnull(tcp.Box9,0) = 1) 
				AND (trp.IDRespuestaPregunta IS NOT NULL 
					AND trp.Respuesta IS NOT NULL 
					AND (tcp.IDTipoPregunta not in (8, 9))) 
				AND tcp.Vista = 1 THEN 1
			WHEN 
				(isnull(tcp.EsRequerida,0) = 1) 
				AND (isnull(tcp.Box9,0) = 1) 
				AND (isnull(tcp.Box9EsRequerido,0) = 1) 
				AND (trp.IDRespuestaPregunta IS NOT NULL 
					AND trp.Respuesta IS NOT NULL 
					AND trp.Box9DesempenioActual IS NOT NULL 
					AND trp.Box9DesempenioFuturo IS NOT null) 
				AND tcp.Vista = 1 THEN 1
			WHEN (isnull(tcp.EsRequerida,0) = 1) 
				AND (isnull(tcp.Box9EsRequerido,0) = 0) 
				AND (trp.IDRespuestaPregunta IS NOT NULL 
					AND trp.Respuesta IS NOT NULL )
				AND tcp.Vista = 1 THEN 1
			WHEN (isnull(tcp.EsRequerida,0) = 1) 
				AND (isnull(tcp.Box9,0) = 0) 
				AND (isnull(tcp.Box9EsRequerido,0) = 1) 
				AND (trp.IDRespuestaPregunta IS NOT NULL 
					AND trp.Respuesta IS NOT NULL )
				AND tcp.Vista = 1 THEN 1
			ELSE 0
		END
	INTO #tmpPreguntasPruebas
	FROM Evaluacion360.tblCatGrupos tcg with (nolock)
		JOIN Evaluacion360.tblCatPreguntas tcp with (nolock) ON tcg.IDGrupo = tcp.IDGrupo
		LEFT JOIN Evaluacion360.tblRespuestasPreguntas trp with (nolock) ON tcp.IDPregunta = trp.IDPregunta
	WHERE tcg.TipoReferencia= 4 AND tcg.IDReferencia = @IDEvaluacionEmpleado
	--AND tcp.IDPregunta = 3425

	IF (not exists(SELECT TOP 1 1 
				 FROM #tmpPreguntasPruebas tpp
				 WHERE tpp.Completa = 0) AND @IDEstatusActualPrueba <> 13) 
	BEGIN
		/*Se le asigna el estatus de Completada a la Prueba*/
		insert Evaluacion360.tblEstatusEvaluacionEmpleado(IDEvaluacionEmpleado,IDEstatus,IDUsuario)
		SELECT @IDEvaluacionEmpleado,13,@IDUsuario

		EXEC [Evaluacion360].[spActualizarProgresoEvaluacionEmpleado] @IDEvaluacionEmpleado = @IDEvaluacionEmpleado
		EXEC [Evaluacion360].[spCalcularValoresGrupos] @IDEvaluacionEmpleado = @IDEvaluacionEmpleado,@IDEstatusActualPrueba = 13
		EXEC [Evaluacion360].[spActualizarProgresoProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario 
		EXEC [Evaluacion360].[spCrearNotificacionEvaluacionEmpleado] @IDEvaluacionEmpleado = @IDEvaluacionEmpleado, @TipoAccion = 1,@IDUsuario = @IDUsuario 
		EXEC [Evaluacion360].[spCompletarProyecto]  @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario 

		SELECT cast(1 AS bit) AS Completa
				,case when @IDEstatusActualPrueba <> 13 then cast(1 AS bit) else cast(0 AS bit) end Redireccionar
	END ELSE 
	BEGIN IF (@IDEstatusActualPrueba < 12)
		BEGIN
			insert Evaluacion360.tblEstatusEvaluacionEmpleado(IDEvaluacionEmpleado,IDEstatus,IDUsuario)
			SELECT @IDEvaluacionEmpleado,12,@IDUsuario

			--EXEC [Evaluacion360].[spCalcularValoresGrupos] @IDEvaluacionEmpleado = @IDEvaluacionEmpleado,@IDEstatusActualPrueba = 13
			--EXEC [Evaluacion360].[spActualizarProgresoProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario 
		end;

		EXEC [Evaluacion360].[spActualizarProgresoEvaluacionEmpleado] @IDEvaluacionEmpleado = @IDEvaluacionEmpleado
		EXEC [Evaluacion360].[spCalcularValoresGrupos] @IDEvaluacionEmpleado = @IDEvaluacionEmpleado,@IDEstatusActualPrueba = 13
		EXEC [Evaluacion360].[spActualizarProgresoProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario 

		SELECT case when @IDEstatusActualPrueba = 13 then cast(1 AS bit) else cast(0 AS bit) end AS Completa
				,cast(0 AS bit) AS Redireccionar
	END;

	--if exists(select top 1 1 
	--		from [Evaluacion360].[tblRespuestasPreguntas]
	--		where IDEvaluacionEmpleado = @IDEvaluacionEmpleado  
	--			and IDPregunta = @IDPregunta  )
	--begin
	--	update [Evaluacion360].[tblRespuestasPreguntas]  
	--	set Respuesta = @Respuesta
	--		,FechaHoraRespuesta =  getdate()
	--	where IDEvaluacionEmpleado = @IDEvaluacionEmpleado  
	--			and IDPregunta = @IDPregunta
	--end else
	--begin
	--	insert [Evaluacion360].[tblRespuestasPreguntas](IDEvaluacionEmpleado,IDPregunta,Respuesta,FechaHoraRespuesta) 
	--	select @IDEvaluacionEmpleado,@IDPregunta,@Respuesta,getdate()
	--end;

	--select *
	--from [Evaluacion360].[tblRespuestasPreguntas]

	--delete [Evaluacion360].[tblRespuestasPreguntas]
	--alter table [Evaluacion360].[tblRespuestasPreguntas]
	--	--add Box9DesempenioActual int		
	--	add Box9DesempenioFuturo int
GO
