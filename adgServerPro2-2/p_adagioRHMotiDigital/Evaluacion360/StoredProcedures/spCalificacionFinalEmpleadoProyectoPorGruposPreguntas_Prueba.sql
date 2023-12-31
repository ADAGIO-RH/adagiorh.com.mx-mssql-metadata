USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spCalificacionFinalEmpleadoProyectoPorGruposPreguntas_Prueba] (
	@IDProyecto int
) as
	SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END

		
	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempEvaluacionesCompletas') is not null drop table #tempEvaluacionesCompletas;
	
	

	select ee.*
		,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,estatus.Estatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock) on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado 
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on eee.IDEstatus = estatus.IDEstatus
	where ep.IDProyecto = @IDProyecto

	select  ep.idempleado,em.IDEvaluacionEmpleado,em.IDTipoRelacion,ctp.Relacion, ep.IDProyecto
	INTO #tempEvaluacionesCompletas
	from [Evaluacion360].[tblEvaluacionesEmpleados] em
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on em.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
	where ep.IDProyecto = @IDProyecto and estatus.IDEstatus = 13 

    select 
        em.*,
        cg.*,
		tctg.*,
        p.*,
        rp.*,
        cap.Descripcion as DescProy
	from [Evaluacion360].[tblCatGrupos] cg
		inner join  #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
		inner join Evaluacion360.tblCatTipoGrupo tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
        inner join Evaluacion360.tblCatPreguntas p on cg.IDGrupo = p.IDGrupo
        inner join rh.tblEmpleadosMaster em ON em.IDEmpleado = e.IDEmpleado
        inner join Evaluacion360.tblCatProyectos cap on cap.IDProyecto = e.IDProyecto
        left join [Evaluacion360].[tblRespuestasPreguntas] rp on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
	where (cg.TipoReferencia = 4)


    

GO
