USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Totales Empleado proyecto por Relacion
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2023-03-01
** Paremetros		:              

** DataTypes Relacionados: 
	
	Si se modifica el result set se este sp, será requerido modicar los siguientes sps:
	 - [Evaluacion360].[spBuscarTotalesParticipantesDeEmpleadoProyecto]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   proc [Evaluacion360].[spCalificacionFinalEmpleadoProyectoPorRelacion] (
	@IDEmpleadoProyecto int
) as

	--declare  @IDEmpleadoProyecto int = 527

	SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END

	declare 
		@MaxValorEscalaValoracion decimal(10,2) = 0.0
		,@TipoPreguntaEscala int = 0,
        @IDIdioma VARCHAR(max);
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx') /* 8: Escala proyecto | 9: Escala Grupo*/

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempEvaluacionesCompletas') is not null drop table #tempEvaluacionesCompletas;
	if object_id('tempdb..#tempEstadisticos') is not null drop table #tempEstadisticos;
	if object_id('tempdb..#tempEstadisticosFinal') is not null drop table #tempEstadisticosFinal;
	if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;

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
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto

	select  em.IDEvaluacionEmpleado,em.IDTipoRelacion,
    JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
	INTO #tempEvaluacionesCompletas
	from [Evaluacion360].[tblEvaluacionesEmpleados] em
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on em.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto and estatus.IDEstatus = 13 /*Estatus COMPLETA*/


	--select 
	--	cg.*
	--		,tctg.Nombre AS TipoGrupo
	--		--,e.*
	--INTO #tempGrupos
	--from (
	--	select distinct gg.*
	--	from [Evaluacion360].[tblCatGrupos] gg
	--		join Evaluacion360.tblCatPreguntas p on p.IDGrupo = gg.IDGrupo 
	--	where (gg.TipoReferencia = 4) and isnull(p.Calificar, 0) = 1
	--) cg

	----join  #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
	--JOIN [Evaluacion360].[tblCatTipoGrupo] tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
	--where cg.IDReferencia in (select IDEvaluacionEmpleado from #tempEvaluacionesCompletas)

	select cg.*
			,tctg.Nombre AS TipoGrupo
			,e.*
	INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] cg
		join Evaluacion360.tblCatPreguntas p on p.IDGrupo = cg.IDGrupo 
		join  #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
		JOIN [Evaluacion360].[tblCatTipoGrupo] tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
	where (cg.TipoReferencia = 4)  and isnull(p.Calificar, 0) = 1

	--delete g
	--from #tempGrupos g
	--	left join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo and 
	--		isnull(p.Calificar, 0) = 1
	--where p.IDPregunta is null

	select
		IDTipoRelacion
		,Relacion
		,cast(SUM(isnull(g.Porcentaje,0.0)) / count(g.IDTipoGrupo) AS decimal(10,2)) AS Porcentaje
		,cast(SUM(isnull(g.Promedio,0.0)) / count(g.IDTipoGrupo) AS decimal(10,2)) AS Promedio
	from #tempGrupos g
	group by IDTipoRelacion, Relacion
GO
