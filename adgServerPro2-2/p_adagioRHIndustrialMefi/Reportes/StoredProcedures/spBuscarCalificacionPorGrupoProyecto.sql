USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Calificaciones por grupo y proyecto
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


	 exec [Reportes].[spBuscarCalificacionPorGrupoProyecto] 36,1
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2022-10-28			Aneudy Abreu	Se agrega validación para que no se consideren las preguntas
									con un valor final de respuesta -1 en los promedios
--***************************************************************************************************/
CREATE proc [Reportes].[spBuscarCalificacionPorGrupoProyecto](
	@IDProyecto int 
	,@IDUsuario int
) as

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

	 declare 
		--@IDProyecto int = 36
		--,@IDEmpleado int = 20310
		@MaxValorEscalaValoracion decimal(10,2) = 0.0
		,@TipoPreguntaEscala int = 8 /* 8: Escala proyecto | 9: Escala Grupo*/
         ,@IDIdioma VARCHAR(max);
        
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempEvaluacionesCompletas') is not null drop table #tempEvaluacionesCompletas;
	if object_id('tempdb..#tempEstadisticos') is not null drop table #tempEstadisticos;
	if object_id('tempdb..#tempEstadisticosFinal') is not null drop table #tempEstadisticosFinal;

	IF (@TipoPreguntaEscala = 8) 
	BEGIN
		if object_id('tempdb..#tempGrupos') is not null
			drop table #tempGrupos;

		select @MaxValorEscalaValoracion = max(Valor)
		from [Evaluacion360].[tblEscalasValoracionesProyectos]
		where IDProyecto = @IDProyecto

		select ee.*
			,eee.IDEstatusEvaluacionEmpleado
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
		where ep.IDProyecto = @IDProyecto -- and estatus.IDEstatus = 13 /*Estatus COMPLETA*/

		select cg.*
			,tctg.Nombre AS TipoGrupo
			,GrupoEscala = case when exists (select top 1 1 
											from [Evaluacion360].[tblCatPreguntas] 
											where IDGrupo = cg.IDGrupo and (IDTipoPregunta = @TipoPreguntaEscala) /*Escala*/)
								then cast(1 as bit) else cast(0 as bit) end
		INTO #tempGrupos
		from [Evaluacion360].[tblCatGrupos] cg
			join  #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
			JOIN [Evaluacion360].[tblCatTipoGrupo] tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
		where (cg.TipoReferencia = 4)
 
		SELECT
			cg.IDTipoGrupo 
			,cg.TipoGrupo
			,cast(count(*) as decimal(10,1)) as TotalPreguntas
			--,count(*) * @MaxValorEscalaValoracion as MaximaCalificacionPosible
			, @MaxValorEscalaValoracion as MaximaCalificacionPosible
			,SUM(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionObtenida
			,min(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionMinimaObtenida
			,max(cast(isnull(rp.Respuesta,0) as decimal(10,1))) as CalificacionMaxinaObtenida
		INTO #tempEstadisticos
		from #tempGrupos cg
			join [Evaluacion360].[tblCatTipoGrupo] ctg  on cg.IDTipoGrupo = ctg.IDTipoGrupo
			join [Evaluacion360].[tblCatPreguntas] p on cg.IDGrupo = p.IDGrupo
			--join [Evaluacion360].[tblQuienResponderaPregunta] qrp on qrp.IDPregunta = p.IDPregunta and (cg.IDTipoRelacion = case when qrp.IDTipoRelacion = 5 then cg.IDTipoRelacion else qrp.IDTipoRelacion end) /*Revisar esta parte, se deben de quitar las preguntas de la prueba al generar dicha prueba segun el tipo de relación*/
			left join [Evaluacion360].[tblRespuestasPreguntas] rp on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
			left join [Evaluacion360].[tblCatCategoriasPreguntas] cp on p.IDCategoriaPregunta = cp.IDCategoriaPregunta
		where (cg.GrupoEscala = 1 ) and isnull(rp.ValorFinal, 0) != -1 -- and p.Descripcion = @Pregunta
		group by cg.IDTipoGrupo ,cg.TipoGrupo 
	END
	ELSE
	BEGIN
		select @MaxValorEscalaValoracion = max(Valor)
		from [Evaluacion360].[tblEscalasValoracionesProyectos]
		where IDProyecto = @IDProyecto
	END;

	select *
		,cast((CalificacionObtenida * 100) / (MaximaCalificacionPosible * TotalPreguntas)  as decimal(10,1))as Porcentaje
		,cast(CalificacionObtenida / TotalPreguntas  as decimal(10,1)) as Promedio
	INTO #tempEstadisticosFinal
	from #tempEstadisticos

	select *
	from #tempEstadisticosFinal
	, (SELECT 
		cast(sum(Porcentaje)/count(#tempEstadisticosFinal.IDTipoGrupo) AS decimal(10,1)) AS PorcentajeGeneral
		,cast(sum(Promedio)/count(#tempEstadisticosFinal.IDTipoGrupo) AS decimal(10,1)) AS PromedioGeneral
		FROM #tempEstadisticosFinal
		) SUMGrupos
GO
