USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarCalificacion9BoxEmpleadoPorProyecto](
	@IDEmpleado int 
	,@IDProyecto int 
	,@IDUsuario int
) as

--declare @IDEmpleado int = 20310
--		,@IDProyecto int = 43

--select rp.Box9DesempenioActual,rp.Box9DesempenioFuturo
--from Evaluacion360.tblEmpleadosProyectos ep
--	join Evaluacion360.tblEvaluacionesEmpleados ee on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
--	join Evaluacion360.tblCatGrupos g on g.IDReferencia = ee.IDEvaluacionEmpleado and g.TipoReferencia = 4
--	join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
--	join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
--where ep.IDProyecto = @IDProyecto and ep.IDEmpleado = @IDEmpleado and Box9 = 1


select SUM(rp.Box9DesempenioActual) / COUNT(*) as Box9DesempenioActual
		,sum(rp.Box9DesempenioFuturo) /COUNT(*) as Box9DesempenioFuturo
from Evaluacion360.tblEmpleadosProyectos ep
	join Evaluacion360.tblEvaluacionesEmpleados ee on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
	join Evaluacion360.tblCatGrupos g on g.IDReferencia = ee.IDEvaluacionEmpleado and g.TipoReferencia = 4
	join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
	join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
where ep.IDProyecto = @IDProyecto and ep.IDEmpleado = @IDEmpleado and p.Box9 = 1

--select 1 as Box9DesempenioActual, 2 as Box9DesempenioFuturo
--select * from Evaluacion360.tblEmpleadosProyectos
GO
