USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Insertar / Actualizar Preguntas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-26
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-10-08			Aneudy Abreu	Se agregó parámetro Chk
2019-02-07			Aneudy Abreu	Se agregaron los campos  Box9EsRequerido,Comentario,ComentarioEsRequerido 	
2019-03-01			Aneudy Abreu	Se agregó el campo MaximaCalificacionPosible
2022-07-26			Aneudy Abreu	Se agregó validación para que si una pregunta No se califica el valor de
									las posibles respuesta se 0
2022-08-02			Javier Paredes  Se elimino el codigo que hacia referencia a @ListaIDsResponderanPregunta
***************************************************************************************************/
CREATE proc [Evaluacion360].[spIUPregunta](
	 @IDPregunta	int
	,@IDTipoPregunta	int
	,@IDGrupo int
	,@IDCategoriaPregunta int = null
	,@Descripcion	varchar(max)
	,@EsRequerida	bit
	,@Calificar	bit
	,@Box9 bit
	,@dtPosiblesRespuestas [Evaluacion360].[dtPosiblesRespuestasPreguntas] readonly
	,@Box9EsRequerido	bit
	,@Comentario	bit
	,@ComentarioEsRequerido	bit
	,@IDIndicador int = null
	,@IDUsuario int
) as
	declare 
		@MaximaCalificacionPosible decimal(10,1)  = 0.0,
		@Deslizante INT = 6,
		@FuncionClave INT = 11,
		@IDTipoReferenciaGrupo int,
		@IDReferencia int,
		@ID_TIPO_REFERENCIA_GRUPO_PROYECTO int = 1,
		@ID_TIPO_PROYECTO_CLIMA_LABORAL int = 3
	;

	select 
		@IDTipoReferenciaGrupo	= TipoReferencia,
		@IDReferencia			= IDReferencia
	from Evaluacion360.tblCatGrupos 
	where IDGrupo = @IDGrupo

	select @MaximaCalificacionPosible = max(Valor)
	from @dtPosiblesRespuestas

	if (@IDTipoPregunta in (1,8,9))
	begin
		select 
			@Calificar = 1
	end; 

	set @IDCategoriaPregunta	= case when ISNULL(@IDCategoriaPregunta, 0) = 0 then null else @IDCategoriaPregunta end
	set @IDIndicador			= case when ISNULL(@IDIndicador, 0) = 0 then null else @IDIndicador end

	if (isnull(@IDPregunta,0) = 0 or @IDPregunta is null)
	begin
		insert into [Evaluacion360].[tblCatPreguntas](IDTipoPregunta,IDGrupo,IDCategoriaPregunta,Descripcion,EsRequerida,Calificar,Box9,Box9EsRequerido,Comentario,ComentarioEsRequerido,MaximaCalificacionPosible, IDIndicador)
		select @IDTipoPregunta,@IDGrupo,@IDCategoriaPregunta,upper(@Descripcion),@EsRequerida,@Calificar,@Box9,@Box9EsRequerido,@Comentario,@ComentarioEsRequerido,@MaximaCalificacionPosible, @IDIndicador

		set @IDPregunta = @@IDENTITY

		insert into Evaluacion360.tblPosiblesRespuestasPreguntas(IDPregunta,OpcionRespuesta,Valor)
		select @IDPregunta,case when (@IDTipoPregunta != @Deslizante AND @IDTipoPregunta != @FuncionClave) then upper(OpcionRespuesta) else OpcionRespuesta end, case when isnull(@Calificar, 0) = 1 then Valor else 0 end
		from @dtPosiblesRespuestas
	end else
	begin
		update [Evaluacion360].[tblCatPreguntas] 
			set	 
				IDTipoPregunta				= @IDTipoPregunta	
				,IDGrupo					= @IDGrupo
				,IDCategoriaPregunta		= @IDCategoriaPregunta
				,Descripcion				= upper(@Descripcion)
				,EsRequerida				= @EsRequerida	
				,Calificar					= @Calificar	
				,Box9						= @Box9	
				,Box9EsRequerido			= @Box9EsRequerido
				,Comentario					= @Comentario
				,ComentarioEsRequerido		= @ComentarioEsRequerido
				,MaximaCalificacionPosible	= @MaximaCalificacionPosible
				,IDIndicador				= @IDIndicador
		where IDPregunta = @IDPregunta

		MERGE Evaluacion360.tblPosiblesRespuestasPreguntas AS TARGET
		USING @dtPosiblesRespuestas as SOURCE
		on TARGET.IDPosibleRespuesta = SOURCE.IDPosibleRespuesta
		WHEN MATCHED THEN
			update 
				set 
					TARGET.OpcionRespuesta				= case when (@IDTipoPregunta != @Deslizante AND @IDTipoPregunta != @FuncionClave) then upper(SOURCE.OpcionRespuesta) else SOURCE.OpcionRespuesta end
					,TARGET.Valor						= case when isnull(@Calificar, 0) = 1 then SOURCE.Valor else 0 end 
					,TARGET.CreadoParaIDTipoPregunta	= @IDTipoPregunta
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDPregunta,OpcionRespuesta,Valor,CreadoParaIDTipoPregunta)
			values(SOURCE.IDPregunta,case when (@IDTipoPregunta != @Deslizante AND @IDTipoPregunta != @FuncionClave) then upper(SOURCE.OpcionRespuesta) else SOURCE.OpcionRespuesta end,SOURCE.Valor,@IDTipoPregunta)
		WHEN NOT MATCHED BY SOURCE and TARGET.IDPregunta = @IDPregunta
		-- AND (TARGET.CreadoParaIDTipoPregunta <> @IDTipoPregunta) 
		THEN 
		DELETE;
	end

	if (@IDTipoReferenciaGrupo = @ID_TIPO_REFERENCIA_GRUPO_PROYECTO)
	begin
		if (
			(
				select IDTipoProyecto
				from Evaluacion360.tblCatProyectos
				where IDProyecto = @IDReferencia
			) = @ID_TIPO_PROYECTO_CLIMA_LABORAL
		)
		begin
			exec Evaluacion360.spGenerarGrupoPreguntasRelevanciaIndicadores @IDReferencia
		end
	end

	Exec [Evaluacion360].[spBuscarPreguntas] @IDPregunta = @IDPregunta
GO
