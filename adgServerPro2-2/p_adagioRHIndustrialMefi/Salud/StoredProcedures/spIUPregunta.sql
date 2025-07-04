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
** FechaCreacion	: 2020-05-29
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE proc [Salud].[spIUPregunta](
	 @IDPregunta	int
	,@IDTipoPregunta	int
	,@IDSeccion int
	,@Descripcion	varchar(max)
	,@Calificar	bit
	,@dtPosiblesRespuestas [Evaluacion360].[dtPosiblesRespuestasPreguntas] readonly
	,@IDUsuario int
) as
	declare @MaximaCalificacionPosible decimal(10,1)  = 0.0
	;

	select @MaximaCalificacionPosible = isnull(max(Valor),0)
	from @dtPosiblesRespuestas

	if (isnull(@IDPregunta,0) = 0 or @IDPregunta is null)
	begin
		insert into [Salud].[tblPreguntas](IDTipoPregunta,IDSeccion,Descripcion,Calificar,MaximaCalificacionPosible)
		select @IDTipoPregunta,@IDSeccion,upper(@Descripcion),@Calificar,@MaximaCalificacionPosible

		set @IDPregunta = @@IDENTITY

		insert into [Salud].tblPosiblesRespuestasPreguntas(IDPregunta,OpcionRespuesta,Valor)
		select @IDPregunta,case when @IDTipoPregunta != 6 then upper(OpcionRespuesta) else OpcionRespuesta end,Valor
		from @dtPosiblesRespuestas
	end else
	begin
		update [Salud].[tblPreguntas] 
		set	 IDTipoPregunta				= @IDTipoPregunta	
			,IDSeccion					= @IDSeccion
			,Descripcion				= upper(@Descripcion)
			,Calificar					= @Calificar	
			,MaximaCalificacionPosible	= @MaximaCalificacionPosible
		where IDPregunta = @IDPregunta

		MERGE [Salud].tblPosiblesRespuestasPreguntas AS TARGET
		USING @dtPosiblesRespuestas as SOURCE
		on TARGET.IDPosibleRespuesta = SOURCE.IDPosibleRespuesta
		WHEN MATCHED THEN
			update 
				set TARGET.OpcionRespuesta			= case when @IDTipoPregunta != 6 then upper(SOURCE.OpcionRespuesta) else SOURCE.OpcionRespuesta end
				,TARGET.Valor						= SOURCE.Valor
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDPregunta,OpcionRespuesta,Valor)
			values(SOURCE.IDPregunta,case when @IDTipoPregunta != 6 then upper(SOURCE.OpcionRespuesta) else SOURCE.OpcionRespuesta end,SOURCE.Valor)
		WHEN NOT MATCHED BY SOURCE and TARGET.IDPregunta = @IDPregunta
		-- AND (TARGET.CreadoParaIDTipoPregunta <> @IDTipoPregunta) 
		THEN 
		DELETE;
	end

	exec [Salud].[spActualizarValorMaximoSeccion] @IDSeccion
	exec [Salud].[spBuscarPreguntas] @IDPregunta = @IDPregunta
GO
