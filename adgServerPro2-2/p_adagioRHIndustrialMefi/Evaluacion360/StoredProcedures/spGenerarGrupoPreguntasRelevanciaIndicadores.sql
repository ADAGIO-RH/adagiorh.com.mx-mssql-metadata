USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spGenerarGrupoPreguntasRelevanciaIndicadores](
	@IDProyecto int
) as
	declare 
		--@IDProyecto int = 126,
		@TIPO_REFERENCIA_PROYECTO int = 1,
		@ID_TIPO_GRUPO_SECCION int = 5,
		@ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR int = 6,
		@ID_TIPO_PREGUNTA_RANKING int = 10,
		@ID_TIPO_PREGUNTA_TEXT_SIMPLE int = 4,

		@IDGrupoNuevo int,
		@IDPreguntaRankingNueva int,
		@IDPreguntaTextoSimpleNueva int
	;

	if not exists(select top 1 1
				from Evaluacion360.tblCatGrupos g
				where g.TipoReferencia = @TIPO_REFERENCIA_PROYECTO and g.IDReferencia = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR)
	begin
		insert Evaluacion360.tblCatGrupos(IDTipoGrupo, Nombre, Descripcion, TipoReferencia, IDReferencia, IDTipoPreguntaGrupo, Activo)
		select 
			@ID_TIPO_GRUPO_SECCION, 
			'RELEVANCIA DE INDICADORES Y COMENTARIOS',
			'ORDENA LOS SIGUIENTES FACTORES CON BASE EN LA RELEVANCIA QUE TIENEN PARA TI COMO COLABORADOR;  DESDE EL FACTOR QUE REQUIERA MEJORAS INMEDIATAS Y ASÍ SUCESIVAMENTE HASTA EL MENOS URGENTE.',
			@TIPO_REFERENCIA_PROYECTO,
			@IDProyecto,
			@ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR,
			cast(1 as bit) as Activo

		set @IDGrupoNuevo = SCOPE_IDENTITY()
	end else
	begin
		select top 1 @IDGrupoNuevo = IDGrupo
		from Evaluacion360.tblCatGrupos g
		where g.TipoReferencia = @TIPO_REFERENCIA_PROYECTO and g.IDReferencia = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR
	end

	if exists (select top 1 1
			from Evaluacion360.tblCatPreguntas
			where IDGrupo = @IDGrupoNuevo and IDTipoPregunta = @ID_TIPO_PREGUNTA_RANKING)
	begin
		select top 1 @IDPreguntaRankingNueva = IDPregunta
		from Evaluacion360.tblCatPreguntas
		where IDGrupo = @IDGrupoNuevo and IDTipoPregunta = @ID_TIPO_PREGUNTA_RANKING
	end else
	begin
		insert Evaluacion360.tblCatPreguntas(IDTipoPregunta, IDGrupo, Descripcion, EsRequerida, Calificar, Box9, Comentario)
		select
			@ID_TIPO_PREGUNTA_RANKING,
			@IDGrupoNuevo,
			'ORDENA LOS SIGUIENTES FACTORES CON BASE EN LA RELEVANCIA QUE TIENEN PARA TI COMO COLABORADOR',
			cast(1 as bit) as EsRequerida,
			cast(0 as bit) as Calificar,
			cast(0 as bit) as Box9,
			cast(0 as bit) as Comentario

		set @IDPreguntaRankingNueva = SCOPE_IDENTITY()
	end


	if object_id('tempdb..#tempIndicadores') is not null drop table #tempIndicadores;

	select distinct 
		i.IDIndicador, 
		i.Nombre as Indicador, 
		FORMATMESSAGE('Indicador: %s: Descripción: %s', i.Nombre, i.Descripcion) as Pregunta, 
		@IDGrupoNuevo as IDGrupo,
		@IDPreguntaRankingNueva as IDPregunta,
		FORMATMESSAGE('{ "IDIndicador": %d }', i.IDIndicador) as JSONData
	INTO #tempIndicadores
	from Evaluacion360.tblCatGrupos g
		join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
		join Evaluacion360.tblCatIndicadores i on i.IDIndicador = p.IDIndicador
	where g.TipoReferencia = @TIPO_REFERENCIA_PROYECTO and g.IDReferencia = @IDProyecto

	/*
	{
		"IDIndicador": 1
	}
	*/

	BEGIN TRY
		BEGIN TRAN 
			MERGE Evaluacion360.[tblPosiblesRespuestasPreguntas] AS TARGET
			USING #TempIndicadores as SOURCE
				on 
					TARGET.IDPregunta = SOURCE.IDPregunta
				and cast(JSON_VALUE(TARGET.JSONData, '$.IDIndicador') as int) = SOURCE.IDIndicador
			WHEN MATCHED THEN
				update
					set 
						TARGET.OpcionRespuesta = SOURCE.Indicador
						,TARGET.Valor = 0
						,TARGET.JSONData = SOURCE.JSONData
			WHEN NOT MATCHED BY TARGET THEN
				INSERT(IDPregunta, OpcionRespuesta, Valor, JSONData)
				values(SOURCE.IDPregunta, SOURCE.Indicador, 0, SOURCE.JSONData)
			--OUTPUT $action,
			--DELETED.*,
			--INSERTED.*
			;

		COMMIT TRAN 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN 
		select ERROR_MESSAGE() as Error
	END CATCH

	DECLARE @archive TABLE (
		ActionType VARCHAR(50),
		IDPregunta INT,
		IDIndicador INT,
		OpcionRespuesta varchar(max)
	);

	BEGIN TRY
		BEGIN TRAN 
			MERGE Evaluacion360.tblCatPreguntas AS TARGET
			USING #TempIndicadores as SOURCE
				on 
					TARGET.IDIndicador	= SOURCE.IDIndicador
				and TARGET.IDGrupo		= SOURCE.IDGrupo
				and TARGET.IDTipoPRegunta	= @ID_TIPO_PREGUNTA_TEXT_SIMPLE
			WHEN MATCHED THEN
				update
					set 
						TARGET.Descripcion	= SOURCE.Pregunta					
						,TARGET.EsRequerida = 1
						,TARGET.Calificar	= 0
						,TARGET.Box9		= 0
						,TARGET.Comentario	= 0
			WHEN NOT MATCHED BY TARGET THEN
				INSERT(IDTipoPregunta, IDGrupo, Descripcion, EsRequerida, Calificar, Box9, Comentario, IDIndicador)
				values(
					@ID_TIPO_PREGUNTA_TEXT_SIMPLE, 
					SOURCE.IDGrupo, 
					SOURCE.Pregunta, 
					cast(1 as bit),
					cast(0 as bit),
					cast(0 as bit),
					cast(0 as bit),
					SOURCE.IDIndicador
				)
			OUTPUT
				$action AS ActionType,
				inserted.IDPregunta,
				inserted.IDIndicador
				INTO @archive(ActionType, IDPregunta, IDIndicador);
			--DELETED.*,
			--INSERTED.*
			;

		COMMIT TRAN 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN 
		select ERROR_MESSAGE() as Error
	END CATCH

	update a
		set
			a.OpcionRespuesta = 'Que sugieres para mejorar el/la '+ coalesce(i.Indicador, '')
	from @archive a
		join #tempIndicadores i on i.IDIndicador = a.IDIndicador

	BEGIN TRY
		BEGIN TRAN 
			MERGE Evaluacion360.tblPosiblesRespuestasPreguntas AS TARGET
			USING @archive as SOURCE
				on 
					TARGET.IDPregunta	= SOURCE.IDPregunta
			WHEN MATCHED THEN
				update
					set 
						TARGET.OpcionRespuesta = SOURCE.OpcionRespuesta		
						,TARGET.Valor = 0
			WHEN NOT MATCHED BY TARGET THEN
				INSERT(IDPregunta, OpcionRespuesta, Valor)
				values(
					SOURCE.IDPregunta, 
					SOURCE.OpcionRespuesta, 
					0
				)
			;
		COMMIT TRAN 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN 
		select ERROR_MESSAGE() as Error
	END CATCH


	
	/* CALCULA LOS PARAMETROS DE LA TABLA ESCALA RELEVANCIA */
	DECLARE @TotalIndicadores DECIMAL(18,2) = 0
			, @ItemsPorEscala FLOAT
			, @TOTAL_ITEMS_ESCALA DECIMAL(18,2) = 3
			, @RELEVANCIA_BAJA INT = 1
			, @RELEVANCIA_MEDIA INT = 2
			, @RELEVANCIA_ALTA INT = 3

	SELECT @TotalIndicadores = COUNT(IDIndicador) FROM #tempIndicadores
	SELECT @ItemsPorEscala = CEILING(@TotalIndicadores / @TOTAL_ITEMS_ESCALA )

	UPDATE [Evaluacion360].[tblEscalaRelevanciaIndicadores] 
	SET [Max] = @ItemsPorEscala
	WHERE IDProyecto = @IDProyecto
		  AND IndiceRelevancia = @RELEVANCIA_BAJA

	UPDATE [Evaluacion360].[tblEscalaRelevanciaIndicadores] 
	SET [Min] = (SELECT [Max] + 1 FROM [Evaluacion360].[tblEscalaRelevanciaIndicadores] WHERE IDProyecto = @IDProyecto AND IndiceRelevancia = @RELEVANCIA_BAJA),
		[Max] = (SELECT [Max] + @ItemsPorEscala FROM [Evaluacion360].[tblEscalaRelevanciaIndicadores] WHERE IDProyecto = @IDProyecto AND IndiceRelevancia = @RELEVANCIA_BAJA)
	WHERE IDProyecto = @IDProyecto
		  AND IndiceRelevancia = @RELEVANCIA_MEDIA

	UPDATE [Evaluacion360].[tblEscalaRelevanciaIndicadores] 
	SET [Min] = (SELECT [Max] + 1 FROM [Evaluacion360].[tblEscalaRelevanciaIndicadores] WHERE IDProyecto = @IDProyecto AND IndiceRelevancia = @RELEVANCIA_MEDIA),
		[Max] = @TotalIndicadores
	WHERE IDProyecto = @IDProyecto
		  AND IndiceRelevancia = @RELEVANCIA_ALTA



	-- SELECT * FROM #tempIndicadores
	--select *
	--from @archive

	--select *
	--from Evaluacion360.[tblPosiblesRespuestasPreguntas]
	--where IDPregunta = @IDPreguntaRankingNueva



	--select *
	--from Evaluacion360.tblCatGrupos g
	--	join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
	--where g.TipoReferencia = @TIPO_REFERENCIA_PROYECTO and g.IDReferencia = @IDProyecto
GO
