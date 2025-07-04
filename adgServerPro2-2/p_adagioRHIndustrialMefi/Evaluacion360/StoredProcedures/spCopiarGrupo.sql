USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Copia un Grupo desde un tipo de referencia X a uno Y, incluyendo sus preguntes, opciones de respuestas y todas las configuraciones que tiene.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE proc [Evaluacion360].[spCopiarGrupo](
	@CopiarDeTipoReferencia int  = -1
	,@CopiarDeIDReferencia int = -1
	,@CopiarAIDTipoEvaluacion int = null
	,@ATipoReferencia int 
	,@AIDReferencia int
	,@IDGrupo int = 0
	,@IDsPreguntas nvarchar(max) = null
	,@IDTipoEvaluacion INT = 0

)as
	declare 
		@i int = 0
		,@iPre int = 0
		,@DescripcionPregunta varchar(255)
		,@j int = 0
		,@IDGrupoNuevo int
		,@IDPregunta int
		,@Nombre varchar(255)
		,@IDTipoGrupo int = 0
		,@GrupoRepetido varchar(255)

		,@TodasLasPreguntasRequieren9BOX bit = 0
		,@9BOXEsRequerido bit = 0
		,@TodasLasPreguntasSonRequeridas bit = 0
		,@IDImportarRespuestas int
		,@IDProyectoSource	   int
		,@IDProyectoTarget	   int
		,@IDPreguntaSource	   int
		,@IDPreguntaTarget	   int
		,@IDEvaluador int
		,@IDEmpleado int
		,@IDProyecto int
		,@IDPreguntaSourceFinal int
		,@IDTipoPreguntaSourceFinal int
		,@DescripcionPreguntaSource varchar(max)
		,@RespuestaSourceFinal varchar(max)
		,@Respuesta varchar(max)
		,@Box9DesempenioActual	 int
		,@Box9DesempenioFuturo	 int
		,@ValorFinal decimal(18,2)
		,@IDTipoRelacion int
		,@TIPO_REFERENCIA_PROYECTO INT = 1
		,@TIPO_REFERENCIA_COLABORADOR INT = 2
		,@TIPO_REFERENCIA_PUESTO INT = 3
		,@TIPO_REFERENCIA_EVALUACION_EMPLEADO INT = 4

	;

	SET @IDTipoEvaluacion = CASE WHEN ISNULL(@IDTipoEvaluacion, 0) = 0 THEN NULL ELSE @IDTipoEvaluacion END;

	if (@ATipoReferencia = @TIPO_REFERENCIA_PROYECTO) 
	begin
		SELECT @TodasLasPreguntasSonRequeridas = case when lower(Valor) = 'true' then 1 else 0 end
		from [Evaluacion360].[tblConfiguracionAvanzadaProyecto]
		where IDProyecto = @AIDReferencia and IDConfiguracionAvanzada = 6  /* Todas las preguntas de esta prueba son requeridas: */

		SELECT @TodasLasPreguntasRequieren9BOX = case when lower(Valor) = 'true' then 1 else 0 end
		from [Evaluacion360].[tblConfiguracionAvanzadaProyecto]
		where IDProyecto = @AIDReferencia and IDConfiguracionAvanzada = 7  /* Todas las preguntas de escala requieren 9BOX: */

		SELECT @9BOXEsRequerido = case when lower(Valor) = 'true' then 1 else 0 end
		from [Evaluacion360].[tblConfiguracionAvanzadaProyecto]
		where IDProyecto = @AIDReferencia and IDConfiguracionAvanzada = 8  /* 9BOX es requerido: */
	end


	if (@ATipoReferencia = @TIPO_REFERENCIA_EVALUACION_EMPLEADO)
	begin
		select 
			@IDProyecto = ep.IDProyecto
			,@IDEmpleado = ep.IDEmpleado
			,@IDEvaluador = ev.IDEvaluador
			,@IDTipoRelacion = ev.IDTipoRelacion
		from [Evaluacion360].[tblEvaluacionesEmpleados] ev with (nolock)
			join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ep.IDEmpleadoProyecto = ev.IDEmpleadoProyecto
		where ev.IDEvaluacionEmpleado = @AIDReferencia


		SELECT @TodasLasPreguntasSonRequeridas = case when lower(Valor) = 'true' then 1 else 0 end
		from [Evaluacion360].[tblConfiguracionAvanzadaProyecto]
		where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 6  /* Todas las preguntas de esta prueba son requeridas: */

		SELECT @TodasLasPreguntasRequieren9BOX = case when lower(Valor) = 'true' then 1 else 0 end
		from [Evaluacion360].[tblConfiguracionAvanzadaProyecto]
		where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 7  /* Todas las preguntas de escala requieren 9BOX: */

		SELECT @9BOXEsRequerido = case when lower(Valor) = 'true' then 1 else 0 end
		from [Evaluacion360].[tblConfiguracionAvanzadaProyecto]
		where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 8  /* 9BOX es requerido: */

	end;		

	if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;
	
	select IDGrupo,IDTipoGrupo,Nombre,Descripcion,@ATipoReferencia as TipoReferencia,@AIDReferencia as IDReferencia,IDGrupo as CopiadoDeIDGrupo,IDTipoPreguntaGrupo, RequerirComentario, CASE WHEN isnull(@CopiarAIDTipoEvaluacion, 0) = 0 THEN NULL ELSE @CopiarAIDTipoEvaluacion END AS IDTipoEvaluacion
	INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] with (nolock)
	where (TipoReferencia = @CopiarDeTipoReferencia or @CopiarDeTipoReferencia = -1 ) and 
		(IDReferencia = @CopiarDeIDReferencia or @CopiarDeIDReferencia = -1) and
		(IDGrupo = @IDGrupo or @IDGrupo = 0) and
		(IDTipoEvaluacion = @IDTipoEvaluacion or isnull(@IDTipoEvaluacion, 0) = 0)		

	
	select @j = min(IDGrupo)
	from #tempGrupos		

	
	while exists(select top 1 1
				from #tempGrupos where IDGrupo >= @j)
	begin
	
		SELECT @Nombre = Nombre,
			   @IDTipoGrupo = IDTipoGrupo
		FROM #tempGrupos
		WHERE IDGrupo = @j

		
		if not exists (select top 1 1 
					from [Evaluacion360].[tblCatGrupos]
					where IDTipoGrupo = @IDTipoGrupo and Nombre = @Nombre and TipoReferencia = @ATipoReferencia and IDReferencia = @AIDReferencia AND ISNULL(IDTipoEvaluacion, 0) = ISNULL(@CopiarAIDTipoEvaluacion, 0))
		begin
			
			insert [Evaluacion360].[tblCatGrupos](IDTipoGrupo,Nombre,Descripcion,TipoReferencia,IDReferencia,CopiadoDeIDGrupo,IDTipoPreguntaGrupo, RequerirComentario, IDTipoEvaluacion) 
			select IDTipoGrupo,Nombre,Descripcion,TipoReferencia,IDReferencia,CopiadoDeIDGrupo,IDTipoPreguntaGrupo, RequerirComentario, IDTipoEvaluacion
			from #tempGrupos
			where IDGrupo = @j			

			set @IDGrupoNuevo = @@IDENTITY

			if object_id('tempdb..#tempPreguntas') is not null
			drop table #tempPreguntas;

			select p.IDPregunta
			INTO #tempPreguntas
			from [Evaluacion360].[tblCatPreguntas] p  
			where p.IDGrupo = @j and  ( p.IDPregunta in (select cast(item as int) from app.Split(@IDsPreguntas,','))
						or len(isnull(@IDsPreguntas,'')) = 0 )

			select @i = min(IDPregunta)
			from #tempPreguntas

			while exists(select top 1 1
						from #tempPreguntas where IDPregunta >= @i)
			begin
				insert [Evaluacion360].[tblCatPreguntas](IDTipoPregunta,IDGrupo,IDCategoriaPregunta,Descripcion,EsRequerida,Calificar,Box9,Box9EsRequerido,Comentario,ComentarioEsRequerido,MaximaCalificacionPosible, IDIndicador)
				select p.IDTipoPregunta
					,@IDGrupoNuevo
					,p.IDCategoriaPregunta
					,p.Descripcion
					,case 
						when @ATipoReferencia = @TIPO_REFERENCIA_PROYECTO OR @CopiarDeTipoReferencia IN (@TIPO_REFERENCIA_COLABORADOR, @TIPO_REFERENCIA_PUESTO)
							then case when ISNULL(@TodasLasPreguntasSonRequeridas, 0) = 1 then 1 else p.EsRequerida end
							else p.EsRequerida end
					--,p.EsRequerida
					,p.Calificar
					--,case when @ATipoReferencia = 1 then @TodasLasPreguntasRequieren9BOX else p.Box9 end
					,case 
						when @ATipoReferencia = @TIPO_REFERENCIA_PROYECTO OR @CopiarDeTipoReferencia IN (@TIPO_REFERENCIA_COLABORADOR, @TIPO_REFERENCIA_PUESTO)
							then case 
									when p.IDTipoPregunta IN (8,9) 
									then case 
											when ISNULL(@TodasLasPreguntasRequieren9BOX, 0) = 1 
												then 1 
												else p.Box9 
											end
									else 0 end 
							else p.Box9 end
					--p.Box9,
					,case 
						when @ATipoReferencia = @TIPO_REFERENCIA_PROYECTO OR @CopiarDeTipoReferencia IN (@TIPO_REFERENCIA_COLABORADOR, @TIPO_REFERENCIA_PUESTO)
							then case 
									when p.IDTipoPregunta IN (8,9) 
									then case 
											when ISNULL(@9BOXEsRequerido, 0) = 1 
												then 1 
												else p.Box9EsRequerido 
											end
									else 0 end
							else p.Box9EsRequerido end
					--p.Box9EsRequerido
					,p.Comentario
					,p.ComentarioEsRequerido
					,p.MaximaCalificacionPosible
					,p.IDIndicador
				from [Evaluacion360].[tblCatPreguntas] p
				where p.IDPregunta = @i

				set @IDPregunta = @@IDENTITY

				insert Evaluacion360.tblPosiblesRespuestasPreguntas(IDPregunta,OpcionRespuesta,Valor,CreadoParaIDTipoPregunta, JSONData)
				select @IDPregunta,OpcionRespuesta,Valor,CreadoParaIDTipoPregunta, JSONData
				from Evaluacion360.tblPosiblesRespuestasPreguntas
				where IDPregunta = @i

				insert [Evaluacion360].[tblQuienResponderaPregunta](IDPregunta,IDTipoRelacion)
				select @IDPregunta,IDTipoRelacion
				from [Evaluacion360].[tblQuienResponderaPregunta]
				where IDPregunta = @i

				BEGIN -- Importación respuestas
					print 0
					--if ((@ATipoReferencia = 4) and exists (
					--								select top 1 1
					--								from Evaluacion360.tblImportarRespuestas
					--								where IDPreguntaTarget = @i
					--							)
					--	)
					--begin
					--	select 
					--		@IDProyectoSource = IDProyectoSource,
					--		@IDPreguntaSource = IDPreguntaSource,
					--		@IDPreguntaTarget = IDPreguntaTarget
					--	from Evaluacion360.tblImportarRespuestas
					--	where IDProyectoTarget =  @CopiarDeIDReferencia and IDPreguntaTarget = @i

					--	select @DescripcionPreguntaSource = Descripcion
					--	from Evaluacion360.tblCatPreguntas
					--	where IDPregunta = @IDPreguntaSource

					--	--select @i as i, @CopiarDeIDReferencia as IDReferencia, @IDPreguntaSource as IDPreguntaSource

					--	select top 1
					--		@IDPreguntaSourceFinal = p.IDPregunta,
					--		@IDTipoPreguntaSourceFinal = p.IDTipoPregunta,
					--		@RespuestaSourceFinal = rp.Respuesta,
					--		@Box9DesempenioActual = rp.Box9DesempenioActual,
					--		@Box9DesempenioFuturo = rp.Box9DesempenioFuturo,
					--		@ValorFinal = rp.ValorFinal
					--	from Evaluacion360.tblEmpleadosProyectos ep
					--		join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto and ee.IDTipoRelacion = @IDTipoRelacion
					--		join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					--		join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					--		join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
					--	where ep.IDProyecto = @IDProyectoSource
					--		and ep.IDEmpleado = @IDEmpleado 
					--		--and ee.IDEvaluador = @IDEvaluador 
					--		and p.Descripcion = @DescripcionPreguntaSource


					--	if (@IDTipoPreguntaSourceFinal = 2) 
					--	begin
					--		select top 1 @Respuesta =  STUFF(
					--			(select ','+ CAST(IDPosibleRespuesta as varchar(max))
					--				from Evaluacion360.tblPosiblesRespuestasPreguntas
					--				where OpcionRespuesta in (
					--					select OpcionRespuesta
					--					from  Evaluacion360.tblPosiblesRespuestasPreguntas
					--					where IDPosibleRespuesta in (
					--						select item from App.Split(@RespuestaSourceFinal, ',')
					--					) and IDPregunta = @IDPreguntaSourceFinal
					--				)
					--				and IDPregunta = @IDPregunta
					--			FOR XML PATH (''))
					--			, 1, 1, '')
						
					--	end else
					--	if (@IDTipoPreguntaSourceFinal = 5)
					--	begin
					--		select top 1 @Respuesta = IDPosibleRespuesta
					--		from Evaluacion360.tblPosiblesRespuestasPreguntas
					--		where IDPregunta = @IDPregunta and OpcionRespuesta = (select top 1 OpcionRespuesta
					--																from Evaluacion360.tblPosiblesRespuestasPreguntas 
					--																where IDPregunta =@IDPreguntaSourceFinal and IDPosibleRespuesta = @RespuestaSourceFinal)
					--	end else
					--	begin
					--		set @Respuesta = @RespuestaSourceFinal
					--	end

					--	insert Evaluacion360.tblRespuestasPreguntas(IDEvaluacionEmpleado,IDPregunta,Respuesta,FechaHoraRespuesta,Box9DesempenioActual,Box9DesempenioFuturo,ValorFinal)
					--	values(@AIDReferencia, @IDPregunta, @Respuesta, GETDATE(), @Box9DesempenioActual, @Box9DesempenioFuturo, @ValorFinal)
					--	--select 
					--	--	@AIDReferencia,@IDPregunta, Respuesta, GETDATE(), Box9DesempenioActual, Box9DesempenioFuturo, ValorFinal
					--	--from Evaluacion360.tblRespuestasPreguntas
					--	--where IDPregunta = @IDPreguntaSource
					--end
				end

				select @i = min(IDPregunta)
				from #tempPreguntas
				where IDPregunta > @i
			end;

			insert Evaluacion360.tblEscalasValoracionesGrupos(IDGrupo,Nombre,Descripcion,Valor)
			select @IDGrupoNuevo,Nombre,Descripcion,Valor
			from Evaluacion360.tblEscalasValoracionesGrupos
			where IDGrupo = @j
		end else 
		begin
			if object_id('tempdb..#tempGpoPreguntas') is not null
			drop table #tempGpoPreguntas;

			select @GrupoRepetido = IDGrupo
			from [Evaluacion360].[tblCatGrupos]
			where IDTipoGrupo = @IDTipoGrupo and Nombre = @Nombre and TipoReferencia =  @ATipoReferencia and IDReferencia = @AIDReferencia and ISNULL(IDTipoEvaluacion, 0) = ISNULL(@CopiarAIDTipoEvaluacion, 0)
								
			select p.IDPregunta, p.Descripcion
			INTO #tempGpoPreguntas
			from [Evaluacion360].[tblCatPreguntas] p  
			where p.IDGrupo = @j and  ( p.IDPregunta in (select cast(item as int) from app.Split(@IDsPreguntas,','))
						or len(isnull(@IDsPreguntas,'')) = 0 )											
			

			select @iPre = min(IDPregunta)
			from #tempGpoPreguntas			

			while exists(select top 1 1
						from #tempGpoPreguntas where IDPregunta >= @iPre)
			begin												
				select @DescripcionPregunta = Descripcion from #tempGpoPreguntas where IDPregunta = @iPre

				if not exists(select IDPregunta from [Evaluacion360].[tblCatPreguntas] where IDGrupo = @GrupoRepetido and UPPER(REPLACE(Descripcion, ' ', '')) = UPPER(REPLACE(@DescripcionPregunta, ' ', '')))
				begin						
					insert [Evaluacion360].[tblCatPreguntas](IDTipoPregunta,IDGrupo,IDCategoriaPregunta,Descripcion,EsRequerida,Calificar,Box9,Box9EsRequerido,Comentario,ComentarioEsRequerido,MaximaCalificacionPosible, IDIndicador)
					select p.IDTipoPregunta
						,@GrupoRepetido
						,p.IDCategoriaPregunta
						,p.Descripcion
						,case 
							when @ATipoReferencia = 1 
								then case when ISNULL(@TodasLasPreguntasSonRequeridas, 0) = 1 then 1 else p.EsRequerida end
								else p.EsRequerida end
						--,p.EsRequerida
						,p.Calificar
						,case 
							when @ATipoReferencia = 1 
								then case 
										when p.IDTipoPregunta IN (8,9) 
										then case 
												when ISNULL(@TodasLasPreguntasRequieren9BOX, 0) = 1 
													then 1 
													else p.Box9 
												end
										else 0 end 
								else p.Box9 end
						--p.Box9,
						,case 
							when @ATipoReferencia = 1 
								then case 
										when p.IDTipoPregunta IN (8,9) 
										then case 
												when ISNULL(@9BOXEsRequerido, 0) = 1 
													then 1 
													else p.Box9EsRequerido 
												end
										else 0 end
								else p.Box9EsRequerido end
						--,p.Box9EsRequerido
						,p.Comentario
						,p.ComentarioEsRequerido
						,p.MaximaCalificacionPosible
						,p.IDIndicador
					from [Evaluacion360].[tblCatPreguntas] p
					where p.IDPregunta = @iPre

				end
				else
					begin
						print 'Pregunta Repetida'
					end

				select @iPre = min(IDPregunta)
				from #tempGpoPreguntas
				where IDPregunta > @iPre
			end
			
			
		end;
		
		select @j = min(IDGrupo)
		from #tempGrupos
		where IDGrupo > @j
	end;
  --  
GO
