USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Grupos por proyecto
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-07
** Paremetros		:    
	TipoReferencia:
		0 : Catálogo
		1 : Asignado a una Prueba
		2 : Asignado a un colaborador
		3 : Asignado a un puesto
		4 : Asignado a una Prueba final para responder
     
	 Cuando el campo TipoReferencia vale 0 (Catálogo) entonces IDReferencia también vale 0     


	 exec [Reportes].[spBuscarCalificacionesPorCompetenciaYRelacionPorProyecto] @IDProyecto=115
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Reportes].[spBuscarCalificacionesPorCompetenciaYRelacionPorProyecto](
	@IDProyecto int 
	,@IDTipoGrupo int =null
) as
declare  
@IDIdioma VARCHAR(max);
        
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

--@IDEmpleadoProyecto int = 42282
--	,@IDTipoGrupo int = null

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

	 declare @TituloPerfil		nvarchar(max) 
			,@TituloResumen		nvarchar(max) 
			,@TituloEvaluadas	nvarchar(max) 
		--,@MaxValorEscalaValoracion decimal(10,2) = 0.0
		;

	if (@IDTipoGrupo = 1)
	begin
		select  @TituloPerfil = N'<b>Perfil de Competencias:</b> El gráfico de radar del perfil de competencias que se muestra a continuación, nos ilustra los puntajes de cada grupo de calificación en todas las competencias. 
		Los gráficos de radar son útiles para detectar fácilmente las brechas entre las percepciones de los grupos de evaluadores y las observaciones de los comportamientos de un individuo. Las puntuaciones más favorables están hacia el exterior de la tabla.'
			,@TituloResumen= N'<b>Resumen de Competencias:</b> Este informe muestra las calificaciones promedio para cada competencia en la revisión segmentada por grupo de evaluadores. Las columnas Alta y Baja presentan las calificaciones más altas y más bajas presentadas por cada grupo de evaluadores para una competencia determinada.'
			,@TituloEvaluadas = N'<b>Reporte de Competencias Evaluadas:</b> Este informe muestra las calificaciones promedio para cada competencia individual en la revisión segmentada por cada grupo de evaluadores. Las columnas Alto y Bajo presentan las calificaciones más altas y más bajas enviadas por cada grupo de evaluadores para un artículo de revisión determinado. La columna N muestra el número de respuestas enviadas en un grupo de evaluadores dado para un elemento en particular.'
	end
	else if (@IDTipoGrupo = 2)
	begin
		select  @TituloPerfil = N'<b>Perfil de Objetivos KPIs:</b> El gráfico de radar del perfil de KPI que se muestra a continuación, nos ilustra los puntajes de cada grupo de calificación en todas las competencias. 
		Los gráficos de radar son útiles para detectar fácilmente las brechas entre las percepciones de los grupos de evaluadores y las observaciones de los comportamientos de un individuo. Las puntuaciones más favorables están hacia el exterior de la tabla.'
					,@TituloResumen= N'<b>Resumen de Objetivos KPIs:</b> Este informe muestra las calificaciones promedio para cada KPI en la revisión segmentada por grupo de evaluadores. Las columnas Alta y Baja presentan las calificaciones más altas y más bajas presentadas por cada grupo de evaluadores para un Objetivo determinada.'
					,@TituloEvaluadas = N'<b>Reporte de Objetivos Kpis Evaluados:</b> Este informe muestra las calificaciones promedio para cada Objetivo Kpi individual en la revisión segmentada por cada grupo de evaluadores. Las columnas Alto y Bajo presentan las calificaciones más altas y más bajas enviadas por cada grupo de evaluadores para un artículo de revisión determinado. La columna N muestra el número de respuestas enviadas en un grupo de evaluadores dado para un elemento en particular.'

	end
	else if (@IDTipoGrupo = 3)
	begin
		select  @TituloPerfil = N'<b>Perfil de Valores:</b> El gráfico de radar del perfil de valores que se muestra a continuación, nos ilustra los puntajes de cada grupo de calificación en todas las competencias. 
		Los gráficos de radar son útiles para detectar fácilmente las brechas entre las percepciones de los grupos de evaluadores y las observaciones de los comportamientos de un individuo. Las puntuaciones más favorables están hacia el exterior de la tabla.'
					,@TituloResumen= N'<b>Resumen de Valores:</b> Este informe muestra las calificaciones promedio para cada valor en la revisión segmentada por grupo de evaluadores. Las columnas Alta y Baja presentan las calificaciones más altas y más bajas presentadas por cada grupo de evaluadores para un Valor determinada.'
					,@TituloEvaluadas = N'<b>Reporte de Valores Evaluados:</b> Este informe muestra las calificaciones promedio para cada valor individual en la revisión segmentada por cada grupo de evaluadores. Las columnas Alto y Bajo presentan las calificaciones más altas y más bajas enviadas por cada grupo de evaluadores para un artículo de revisión determinado. La columna N muestra el número de respuestas enviadas en un grupo de evaluadores dado para un elemento en particular.'

	end;

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempEvaluacionesCompletas') is not null drop table #tempEvaluacionesCompletas;
	if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;
	if object_id('tempdb..#tempEstadisticos') is not null drop table #tempEstadisticos;

	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) as Estatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock) on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on eee.IDEstatus = estatus.IDEstatus
	where ep.IDProyecto = @IDProyecto 

	select  em.IDEvaluacionEmpleado,em.IDTipoRelacion,
       JSON_VALUE(ctp.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
	INTO #tempEvaluacionesCompletas
	from [Evaluacion360].[tblEvaluacionesEmpleados] em
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on em.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
	where ep.IDProyecto = @IDProyecto
		 and estatus.IDEstatus = 13


	select 
		cg.Nombre 
		,e.Relacion
		,cg.TotalPreguntas
		,max(cg.MaximaCalificacionPosible) as MaximaCalificacionPosible
		,cast(sum(cg.CalificacionObtenida) / count(*)as decimal(10,2)) as CalificacionObtenida
		,cast(sum(cg.Promedio) / count(*) as decimal(10,2)) as Promedio
		,cast(sum(CalificacionObtenida) / SUM(TotalPreguntas)  as decimal(10,2)) as Calificacion
		,@TituloPerfil	  as TituloPerfil	
		,@TituloResumen	  as TituloResumen	
		,@TituloEvaluadas as TituloEvaluadas
	--	,GrupoEscala = case when exists (select top 1 1 
	--									from [Evaluacion360].[tblCatPreguntas] 
	--									where IDGrupo = cg.IDGrupo and IDTipoPregunta = 8 /*Escala*/)
	--						then cast(1 as bit) else cast(0 as bit) end
	--INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] cg
		join  #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
	where (cg.TipoReferencia = 4) and (cg.IDTipoGrupo = @IDTipoGrupo or @IDTipoGrupo is null)
		and isnull(cg.Porcentaje,0.0) > 0.0
	 --and cg.IDTipoPreguntaGrupo in (2,3)
	group by cg.Nombre 
		,e.Relacion
		,cg.TotalPreguntas
GO
