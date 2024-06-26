USE [readOnly_adagioRHHotelesGDLPlaza]
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
	,@ListaIDsResponderanPregunta varchar(255)
	,@dtPosiblesRespuestas [Evaluacion360].[dtPosiblesRespuestasPreguntas] readonly
	,@Box9EsRequerido	bit
	,@Comentario	bit
	,@ComentarioEsRequerido	bit
	,@IDUsuario int
) as
	declare @MaximaCalificacionPosible decimal(10,1)  = 0.0
	;

	select @MaximaCalificacionPosible = max(Valor)
		from @dtPosiblesRespuestas

	if (@IDTipoPregunta in (1,8,9))
	begin
		select @Calificar = 1
		--	,@MaximaCalificacionPosible = 0;
	end; 
	--else 
	--if (@Calificar = 1)
	--begin
	--	select @MaximaCalificacionPosible = max(Valor)
	--	from @dtPosiblesRespuestas
	--end;

	if (isnull(@IDPregunta,0) = 0 or @IDPregunta is null)
	begin
		insert into [Evaluacion360].[tblCatPreguntas](IDTipoPregunta,IDGrupo,IDCategoriaPregunta,Descripcion,EsRequerida,Calificar,Box9,Box9EsRequerido,Comentario,ComentarioEsRequerido,MaximaCalificacionPosible)
		select @IDTipoPregunta,@IDGrupo,@IDCategoriaPregunta,upper(@Descripcion),@EsRequerida,@Calificar,@Box9,@Box9EsRequerido,@Comentario,@ComentarioEsRequerido,@MaximaCalificacionPosible

		set @IDPregunta = @@IDENTITY

		insert into Evaluacion360.tblPosiblesRespuestasPreguntas(IDPregunta,OpcionRespuesta,Valor)
		select @IDPregunta,case when @IDTipoPregunta != 6 then upper(OpcionRespuesta) else OpcionRespuesta end,Valor
		from @dtPosiblesRespuestas
	end else
	begin
		update [Evaluacion360].[tblCatPreguntas] 
		set	 IDTipoPregunta				= @IDTipoPregunta	
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
		where IDPregunta = @IDPregunta

		MERGE Evaluacion360.tblPosiblesRespuestasPreguntas AS TARGET
		USING @dtPosiblesRespuestas as SOURCE
		on TARGET.IDPosibleRespuesta = SOURCE.IDPosibleRespuesta
		WHEN MATCHED THEN
			update 
				set TARGET.OpcionRespuesta			= case when @IDTipoPregunta != 6 then upper(SOURCE.OpcionRespuesta) else SOURCE.OpcionRespuesta end
				,TARGET.Valor						= SOURCE.Valor
				,TARGET.CreadoParaIDTipoPregunta	= @IDTipoPregunta
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDPregunta,OpcionRespuesta,Valor,CreadoParaIDTipoPregunta)
			values(SOURCE.IDPregunta,case when @IDTipoPregunta != 6 then upper(SOURCE.OpcionRespuesta) else SOURCE.OpcionRespuesta end,SOURCE.Valor,@IDTipoPregunta)
		WHEN NOT MATCHED BY SOURCE and TARGET.IDPregunta = @IDPregunta
		-- AND (TARGET.CreadoParaIDTipoPregunta <> @IDTipoPregunta) 
		THEN 
		DELETE;
	end

	if object_id('tempdb..#tempQuienRespondera') is not null
		drop table #tempQuienRespondera;

	select cast(item as int) IDTipoRelacion
	INTO #tempQuienRespondera
	from [App].[Split](@ListaIDsResponderanPregunta,',')
	
	MERGE [Evaluacion360].[tblQuienResponderaPregunta] AS TARGET
	USING #tempQuienRespondera as SOURCE
	on TARGET.IDTipoRelacion	= SOURCE.IDTipoRelacion
		and TARGET.IDPregunta	= @IDPregunta	
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(IDPregunta,IDTipoRelacion)
		values(@IDPregunta,SOURCE.IDTipoRelacion)
	WHEN NOT MATCHED BY SOURCE  and TARGET.IDPregunta = @IDPregunta	 THEN 
	DELETE;

	Exec [Evaluacion360].[spBuscarPreguntas] @IDPregunta = @IDPregunta
GO
