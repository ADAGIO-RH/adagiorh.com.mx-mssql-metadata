USE [p_adagioRHLya]
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
	,@ATipoReferencia int 
	,@AIDReferencia int
	,@IDGrupo int = 0
	,@IDsPreguntas nvarchar(max) = null
)as
	declare @i int = 0
			,@j int = 0
			,@IDGrupoNuevo int
			,@IDPregunta int
			,@Nombre varchar(255)
	
			,@TodasLasPreguntasRequieren9BOX bit = 0
			,@9BOXEsRequerido bit = 0
			,@TodasLasPreguntasSonRequeridas bit = 0

	;

	if (@ATipoReferencia = 1) 
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
	--if (@ATipoReferencia  = 1)
	--begin
	--end;
		
	if object_id('tempdb..#tempGrupos') is not null
		drop table #tempGrupos;
	
	select IDGrupo,IDTipoGrupo,Nombre,Descripcion,@ATipoReferencia as TipoReferencia,@AIDReferencia as IDReferencia,IDGrupo as CopiadoDeIDGrupo,IDTipoPreguntaGrupo
	INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] with (nolock)
	where (TipoReferencia = @CopiarDeTipoReferencia or @CopiarDeTipoReferencia = -1 ) and 
		(IDReferencia = @CopiarDeIDReferencia or @CopiarDeIDReferencia = -1) and
		(IDGrupo = @IDGrupo or @IDGrupo = 0)

	select @j = min(IDGrupo)
	from #tempGrupos

	while exists(select top 1 1
				from #tempGrupos where IDGrupo >= @j)
	begin
		select  @Nombre = Nombre 
		from #tempGrupos
		where IDGrupo = @j

		if not exists (select top 1 1 
					from [Evaluacion360].[tblCatGrupos]
					where Nombre = @Nombre and TipoReferencia =  @ATipoReferencia and IDReferencia = @AIDReferencia)
		begin
			insert [Evaluacion360].[tblCatGrupos](IDTipoGrupo,Nombre,Descripcion,TipoReferencia,IDReferencia,CopiadoDeIDGrupo,IDTipoPreguntaGrupo) 
			select IDTipoGrupo,Nombre,Descripcion,TipoReferencia,IDReferencia,CopiadoDeIDGrupo,IDTipoPreguntaGrupo
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
				insert [Evaluacion360].[tblCatPreguntas](IDTipoPregunta,IDGrupo,IDCategoriaPregunta,Descripcion,EsRequerida,Calificar,Box9,Box9EsRequerido,Comentario,ComentarioEsRequerido,MaximaCalificacionPosible)
				select p.IDTipoPregunta
					,@IDGrupoNuevo
					,p.IDCategoriaPregunta
					,p.Descripcion
					,case when @ATipoReferencia = 1 then @TodasLasPreguntasSonRequeridas else p.EsRequerida end
					,p.Calificar
					,case when @ATipoReferencia = 1 then @TodasLasPreguntasRequieren9BOX else p.Box9 end
					,case when @ATipoReferencia = 1 then @9BOXEsRequerido else p.Box9EsRequerido end
					,p.Comentario
					,p.ComentarioEsRequerido
					,p.MaximaCalificacionPosible
				from [Evaluacion360].[tblCatPreguntas] p
				where p.IDPregunta = @i

				set @IDPregunta = @@IDENTITY

				insert Evaluacion360.tblPosiblesRespuestasPreguntas(IDPregunta,OpcionRespuesta,Valor,CreadoParaIDTipoPregunta)
				select @IDPregunta,OpcionRespuesta,Valor,CreadoParaIDTipoPregunta
				from Evaluacion360.tblPosiblesRespuestasPreguntas
				where IDPregunta = @i

				insert [Evaluacion360].[tblQuienResponderaPregunta](IDPregunta,IDTipoRelacion)
				select @IDPregunta,IDTipoRelacion
				from [Evaluacion360].[tblQuienResponderaPregunta]
				where IDPregunta = @i

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
			--EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			--RETURN 0;
			print 'Competencia Repetida'
		end;
		
		select @j = min(IDGrupo)
		from #tempGrupos
		where IDGrupo > @j
	end;
  --  

	 
	----select *
	----from [Evaluacion360].[tblCatGrupos] g with (nolock)
	----	join [Evaluacion360].[tblCatPreguntas] p on g.IDGrupo = p.IDGrupo
	----where TipoReferencia = @CopiarDeTipoReferencia and IDReferencia = @CopiarDeIDReferencia

	--insert [Evaluacion360].[tblCatPreguntas](IDTipoPregunta,IDGrupo,Descripcion,EsRequerida,Calificar,Box9)

	

	--select g.Nombre,p.IDPregunta, p.IDTipoPregunta,g.IDGrupo,p.Descripcion,p.EsRequerida,p.Calificar,p.Box9
	--from [Evaluacion360].[tblCatGrupos] g with (nolock)
	----	join [Evaluacion360].[tblCatGrupos] gCopiado on g.CopiadoDeIDGrupo = gCopiado.IDGrupo
	--	join [Evaluacion360].[tblCatPreguntas] p on g.IDGrupo = p.IDGrupo
	--where g.TipoReferencia = 3 and g.IDReferencia = 15

	--select g.Nombre,p.IDPregunta, p.IDTipoPregunta,g.IDGrupo,p.Descripcion,p.EsRequerida,p.Calificar,p.Box9
	--from [Evaluacion360].[tblCatGrupos] g with (nolock)
	----	join [Evaluacion360].[tblCatGrupos] gCopiado on g.CopiadoDeIDGrupo = gCopiado.IDGrupo
	--	join [Evaluacion360].[tblCatPreguntas] p on g.IDGrupo = p.IDGrupo
	--where g.TipoReferencia = 4 and g.IDReferencia = 105661

	
--	select * from Evaluacion360.tblPosiblesRespuestasPreguntas
--	where IDPregunta in (1036
--,1037
--,1038
--,1039)

--	select * from Evaluacion360.tblPosiblesRespuestasPreguntas
--	where IDPregunta in (1048
--,1049
--,1050
--,1051)

--	delete from 
--	Evaluacion360.tblCatGrupos
--	where IDGrupo in (1055
--,1056
--,1057
--,1059)


	--select g.IDGrupo,p.IDPregunta
	--from [Evaluacion360].[tblCatGrupos] g with (nolock)
	----	join [Evaluacion360].[tblCatGrupos] gCopiado on g.CopiadoDeIDGrupo = gCopiado.IDGrupo
	--	join [Evaluacion360].[tblCatPreguntas] p on g.IDGrupo = p.IDGrupo
	--where g.TipoReferencia = 2 and g.IDReferencia = 149
GO
