USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Preguntas por grupos y valida si existe en el proyecto
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-07-02
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarPreguntasPorGrupoEnProyecto](
	@IDGrupo int 	
	,@IDProyecto int 
	,@IDUsuario int
) as

DECLARE 
@IDIdioma varchar(max);
   select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select p.IDPregunta
		,p.IDTipoPregunta
		,UPPER (JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoPregunta'))) as TipoPregunta
		,p.IDGrupo
		,cg.Nombre as Grupo
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
		,Existe = case when preguntasProyecto.IDPregunta is not null then cast(1 as bit) else cast(0 as bit) end	
		,isnull(p.IDIndicador, 0) as IDIndicador
		,isnull(indicadores.Nombre, 'Sin indicador') as Indicador
	from [Evaluacion360].[tblCatPreguntas] p  with (nolock)			
		join [Evaluacion360].[tblCatTiposDePreguntas] tp  with (nolock) on p.IDTipoPregunta = tp.IDTipoPregunta
		join [Evaluacion360].[tblCatGrupos] cg on p.IDGrupo = cg.IDGrupo
		left join (select pp.* from Evaluacion360.tblCatGrupos pcg  with (nolock)
						join Evaluacion360.tblCatPreguntas pp  with (nolock) on pcg.IDGrupo = pp.IDGrupo
					where /*pcg.TipoReferencia = 1 and pcg.IDReferencia = @IDProyecto AND*/ pcg.IDGrupo = @IDGrupo) preguntasProyecto on p.Descripcion = preguntasProyecto.Descripcion
		left join [Evaluacion360].[tblCatCategoriasPreguntas] ccp  with (nolock) on p.IDCategoriaPregunta = ccp.IDCategoriaPregunta
		left join [Evaluacion360].[tblCatIndicadores] indicadores  with (nolock) on p.IDIndicador = indicadores.IDIndicador
		left join [Evaluacion360].[tblRespuestasPreguntas] rp  with (nolock) on  rp.IDPregunta = p.IDPregunta
	where(p.IDGrupo = @IDGrupo) 
	order by isnull(ccp.Nombre,'Sin categoría asignada') asc
GO
