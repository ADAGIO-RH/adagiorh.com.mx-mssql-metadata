USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarTotalesParticipantesDeEmpleadoProyecto] (
	@IDEmpleadoProyecto int
) as

	--declare  @IDEmpleadoProyecto int = 527

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END	 

	 declare @TotalPorRelacion as table (
		IDTipoRelacion int,
		Relacion varchar(255),
		Porcentaje decimal(10, 2),
		Promedio decimal(10, 2)
	 )
    DECLARE @IDIdioma VARCHAR(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')
	 insert @TotalPorRelacion
	 exec [Evaluacion360].[spCalificacionFinalEmpleadoProyectoPorRelacion] @IDEmpleadoProyecto=@IDEmpleadoProyecto

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
	where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto 


--select * from #tempHistorialEstatusEvaluacion
	select 
		em.IDTipoRelacion
		,JSON_VALUE(ctp.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
		,count(em.IDEvaluacionEmpleado) as Asignados
		,sum(case when estatus.IDEstatus = 13 then 1 else 0 end) Completas 
	INTO #tempTotales
	from [Evaluacion360].[tblEvaluacionesEmpleados] em
		join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
	where em.IDEmpleadoProyecto = @IDEmpleadoProyecto and isnull(em.IDEvaluador, 0) > 0
	group by em.IDTipoRelacion, ctp.Relacion, ctp.Traduccion

	select 
		t.IDTipoRelacion,
		t.Relacion,
		t.Asignados,
		t.Completas,
		(t.Completas * 100) / t.Asignados as TazaDeRespuesta, 
		isnull(totalRelacion.Porcentaje, CAST(0 as decimal(10,2))) as Porcentaje,
		isnull(totalRelacion.Promedio, CAST(0 as decimal(10,2))) as Promedio
	from #tempTotales t
		left join @TotalPorRelacion totalRelacion on totalRelacion.IDTipoRelacion = t.IDTipoRelacion
GO
