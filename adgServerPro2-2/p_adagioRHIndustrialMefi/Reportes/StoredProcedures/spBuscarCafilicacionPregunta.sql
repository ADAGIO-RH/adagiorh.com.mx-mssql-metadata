USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Grupos
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


	 exec [Reportes].[spBuscarCalificacionesPorCompetencia] 41081
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2022-10-28			Aneudy Abreu		Se agrega validación para que no se consideren las preguntas
										con un valor final de respuesta -1 en los promedios
***************************************************************************************************/
CREATE proc [Reportes].[spBuscarCafilicacionPregunta](
	@IDEmpleadoProyecto int 
	,@Pregunta nvarchar(max)
) as
	--declare  @IDEmpleadoProyecto int = 515
	--	,@Pregunta nvarchar(max) = N'CONSIDERA QUE ES MÁS SENCILLO REALIZAR SUS ACTIVIDADES LABORALES DE MANERA REMOTA QUE DE MANERA PRESENCIAL, CUMPLIENDO AL 100% CON SUS OBJETIVOS.'

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

	 declare 
		@IDProyecto int = 0
		,@MaxValorEscalaValoracion decimal(10,2) = 0.0
        ,@IDIdioma VARCHAR(max)
	;
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')
	select @IDProyecto = ep.IDProyecto
	from [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) 
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto 
	
	select @MaxValorEscalaValoracion = max(Valor)
	from [Evaluacion360].[tblEscalasValoracionesProyectos]
	where IDProyecto = @IDProyecto

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
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto 

	select  em.IDEvaluacionEmpleado,
    em.IDTipoRelacion,
   JSON_VALUE(ctp.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
	INTO #tempEvaluacionesCompletas
	from [Evaluacion360].[tblEvaluacionesEmpleados] em
		join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
	where em.IDEmpleadoProyecto = @IDEmpleadoProyecto
		 and estatus.IDEstatus = 13

	select *
		--,GrupoEscala = case when exists (select top 1 1 
		--								from [Evaluacion360].[tblCatPreguntas] 
		--								where IDGrupo = cg.IDGrupo and IDTipoPregunta = 8 /*Escala*/)
		--					then cast(1 as bit) else cast(0 as bit) end
	INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] cg
		join  #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
	where (cg.TipoReferencia = 4)
	
	select 
		Relacion
		,SUM(TotalPreguntas) as TotalPreguntas
		,AVG(MaximaCalificacionPosible) as MaximaCalificacionPosible
		,AVG(cast(isnull(CalificacionObtenida,0) as decimal(10,2))) as CalificacionObtenida
		,min(cast(isnull(CalificacionMinimaObtenida,0) as decimal(10,2))) as CalificacionMinimaObtenida
		,max(cast(isnull(CalificacionMaxinaObtenida,0) as decimal(10,2))) as CalificacionMaxinaObtenida
	INTO #tempEstadisticos
	from (
		select cg.Relacion
			,cast(count(*) as decimal(10,2)) as TotalPreguntas
			--,count(*) * @MaxValorEscalaValoracion as MaximaCalificacionPosible
			,MaximaCalificacionPosible = case when p.IDTipoPregunta IN (8, 11) then @MaxValorEscalaValoracion 
											 when p.IDTipoPregunta = 9 then (select max(Valor) from Evaluacion360.tblEscalasValoracionesGrupos where IDGrupo = p.IDGrupo)
												else p.MaximaCalificacionPosible end	
			,SUM(cast(isnull(rp.ValorFinal,0) as decimal(10,2))) as CalificacionObtenida
			,min(cast(isnull(rp.ValorFinal,0) as decimal(10,2))) as CalificacionMinimaObtenida
			,max(cast(isnull(rp.ValorFinal,0) as decimal(10,2))) as CalificacionMaxinaObtenida
		from #tempGrupos cg
			join [Evaluacion360].[tblCatTipoGrupo] ctg  on cg.IDTipoGrupo = ctg.IDTipoGrupo
			join [Evaluacion360].[tblCatPreguntas] p on cg.IDGrupo = p.IDGrupo
			--join [Evaluacion360].[tblQuienResponderaPregunta] qrp on qrp.IDPregunta = p.IDPregunta and (cg.IDTipoRelacion = case when qrp.IDTipoRelacion = 5 then cg.IDTipoRelacion else qrp.IDTipoRelacion end) /*Revisar esta parte, se deben de quitar las preguntas de la prueba al generar dicha prueba segun el tipo de relación*/
			left join [Evaluacion360].[tblRespuestasPreguntas] rp on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
			left join [Evaluacion360].[tblCatCategoriasPreguntas] cp on p.IDCategoriaPregunta = cp.IDCategoriaPregunta
		where p.Descripcion = @Pregunta and isnull(rp.ValorFinal, 0) != -1 --(cg.GrupoEscala = 1 ) and
		group by cg.Relacion,p.IDGrupo,p.IDTipoPregunta,p.MaximaCalificacionPosible
	) info
	group by Relacion
	--select  Relacion
	--		--,Pregunta
	--		--,N'<p> <b>'+Competencia+' </b> <br/>'+Pregunta+'</p>' as PreguntaYCompetencia
	--		,TotalPreguntas
	--		,MaximaCalificacionPosible
	--		,CalificacionObtenida
	--	--,(CalificacionObtenida * 100) / MaximaCalificacionPosible as Promedio
	--	,cast(CalificacionObtenida / TotalPreguntas as decimal(10,2)) as Calificacion
	--from #tempEstadisticos

	
	select *
		,cast((CalificacionObtenida * 100) / MaximaCalificacionPosible  as decimal(10,2))as Promedio
		,cast(CalificacionObtenida / TotalPreguntas  as decimal(10,2)) as Calificacion
	from #tempEstadisticos
GO
