USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarTotalesParticipantesProyecto] (
	@IDProtecto int
	,@IDUsuario int
) as
Declare 
@IDIdioma VARCHAR(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	--declare  @IDProtecto int = 10
    SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempTotales') is not null drop table #tempTotales;
		 
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
	where ep.IDProyecto = @IDProtecto

	select 
		 JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
		,count(em.IDEvaluacionEmpleado) as Asignados
		,sum(case when estatus.IDEstatus = 13 then 1 else 0 end) Completas 
	INTO #tempTotales
	from [Evaluacion360].[tblEvaluacionesEmpleados] em with (nolock) 
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on em.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [Evaluacion360].[tblCatTiposRelaciones] ctp with (nolock)  on em.IDTipoRelacion = ctp.IDTipoRelacion
		left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
	where ep.IDProyecto = @IDProtecto and isnull(em.IDEvaluador, 0) > 0
	group by ctp.Traduccion

	select *,(Completas * 100) / Asignados as TazaDeRespuesta
	from #tempTotales
GO
