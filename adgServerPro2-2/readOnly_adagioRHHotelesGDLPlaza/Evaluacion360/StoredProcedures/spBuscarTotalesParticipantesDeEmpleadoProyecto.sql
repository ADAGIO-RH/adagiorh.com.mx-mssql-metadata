USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Evaluacion360].[spBuscarTotalesParticipantesDeEmpleadoProyecto] (@IDEmpleadoProyecto int) as

--declare  @IDEmpleadoProyecto int = 41081

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null
			drop table #tempHistorialEstatusEvaluacion;

	if object_id('tempdb..#tempTotales') is not null
			drop table #tempTotales;
		 
	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,estatus.Estatus
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
ctp.Relacion
	,count(em.IDEvaluacionEmpleado) as Asignados
	,sum(case when estatus.IDEstatus = 13 then 1 else 0 end) Completas 
INTO #tempTotales
from [Evaluacion360].[tblEvaluacionesEmpleados] em
	join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
	left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
where em.IDEmpleadoProyecto = @IDEmpleadoProyecto
group by ctp.Relacion


select *,(Completas * 100) / Asignados as TazaDeRespuesta
from #tempTotales

--insert [Evaluacion360].[tblEstatusEvaluacionEmpleado] (IDEvaluacionEmpleado
--,IDEstatus
--,IDUsuario
--,FechaCreacion)
--select 105657,13,1,getdate()

--select * from [Evaluacion360].[tblEvaluacionesEmpleados]
--where IDEvaluacionEmpleado = 105657
GO
