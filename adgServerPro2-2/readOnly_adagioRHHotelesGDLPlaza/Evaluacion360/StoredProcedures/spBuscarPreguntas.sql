USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Preguntas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-26
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-10-08			Aneudy Abreu	Se agregó el sp [spBuscarQuienRespondePregunta]
2019-02-07			Aneudy Abreu	Se agregaron los campos  Box9EsRequerido,Comentario,ComentarioEsRequerido 															 
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarPreguntas](
	@IDPregunta int = 0
	,@IDGrupo int = 0
) as
	
	select p.IDPregunta
		,p.IDTipoPregunta
		,tp.TipoPregunta
		,p.IDGrupo
		,cg.Nombre as Grupo
		,tg.IDTipoGrupo
		,tg.Nombre as TipoGrupo
		,isnull(p.IDCategoriaPregunta,0) as IDCategoriaPregunta
		,isnull(ccp.Nombre,'Sin categoría asignada') as Categoria
		,p.Descripcion
		,p.EsRequerida
		,p.Calificar
		,rp.Respuesta
		,isnull(p.Box9,cast(0 as bit)) Box9
		,isnull(p.Box9EsRequerido,cast(0 as bit)) Box9EsRequerido
		,isnull(p.Comentario,cast(0 as bit)) Comentario
		,isnull(p.ComentarioEsRequerido,cast(0 as bit)) ComentarioEsRequerido
		,(select count(*) from [Evaluacion360].[tblComentariosPregunta] with (nolock) where IDPregunta = p.IDPregunta ) as TotalComentarios
	from [Evaluacion360].[tblCatPreguntas] p
		join [Evaluacion360].[tblCatTiposDePreguntas] tp on p.IDTipoPregunta = tp.IDTipoPregunta
		join [Evaluacion360].[tblCatGrupos] cg on p.IDGrupo = cg.IDGrupo
		join [Evaluacion360].[tblCatTipoGrupo] tg on tg.IDTipoGrupo = cg.IDTipoGrupo
		left join [Evaluacion360].[tblCatCategoriasPreguntas] ccp on p.IDCategoriaPregunta = ccp.IDCategoriaPregunta
		left join [Evaluacion360].[tblRespuestasPreguntas] rp on  rp.IDPregunta = p.IDPregunta
	where (p.IDPregunta = @IDPregunta or @IDPregunta = 0) and (p.IDGrupo = @IDGrupo or @IDGrupo = 0) 
	order by isnull(ccp.Nombre,'Sin categoría asignada') asc

	exec [Evaluacion360].[spBuscarPosiblesRespuestasPreguntas] @IDPregunta = @IDPregunta

	exec [Evaluacion360].[spBuscarQuienRespondePregunta] @IDPregunta = @IDPregunta
GO
