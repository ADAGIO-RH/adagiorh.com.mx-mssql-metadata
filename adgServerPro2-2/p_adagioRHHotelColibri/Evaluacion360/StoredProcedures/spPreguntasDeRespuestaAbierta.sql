USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
----select * from Evaluacion360.tblEmpleadosProyectos where IDProyecto = 75
CREATE proc [Evaluacion360].[spPreguntasDeRespuestaAbierta] (
	@IDProyecto int, 
    @IDUsuario int
) as

--declare 
--	@IDEmpleadoProyecto int = 42293
--	,@IDUsuario int = 1
--	;
	SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END

if object_id('tempdb..#tempMainData') is not null 
    drop table #tempMainData;

 
Select * from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblCatPreguntas catp on catp.IDPregunta = resp.IDPregunta
Inner join Evaluacion360.tblCatGrupos catc on catc.IDGrupo = catp.IDGrupo
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
inner join Evaluacion360.tblCatProyectos cp on ep.IDProyecto = cp.IDProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
Inner join rh.tblEmpleadosMaster EM on EM.IDEmpleado = eve.IDEvaluador
Where cp.IDProyecto = @IDProyecto and IDTipoPregunta  in (4)




GO
