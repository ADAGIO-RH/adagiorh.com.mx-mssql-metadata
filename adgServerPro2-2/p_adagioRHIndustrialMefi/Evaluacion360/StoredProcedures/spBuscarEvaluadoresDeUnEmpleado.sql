USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Evaluacion360].[spBuscarEvaluadoresDeUnEmpleado](
	@IDEmpleado int
	,@IDProyecto int 
	,@IDUsuario int
) as
	--DECLARE @IDEmpleado int = 20310
	--		,@IDProyecto int = 36
	--		;

	if object_id('tempdb..#tempEvaluadores') is not null
			drop table #tempEvaluadores;	

	SELECT tep.IDEmpleadoProyecto
		,tee.IDEvaluacionEmpleado
		,tee.IDEvaluador
		,tem.ClaveEmpleado
		,tem.NOMBRECOMPLETO AS NombreCompleto 
		--DISTINCT tee.IDEvaluador
	INTO #tempEvaluadores
	FROM Evaluacion360.tblEmpleadosProyectos tep
		JOIN Evaluacion360.tblEvaluacionesEmpleados tee ON tep.IDEmpleadoProyecto = tee.IDEmpleadoProyecto
		JOIN RH.tblEmpleadosMaster tem	ON tee.IDEvaluador = tem.IDEmpleado
	WHERE tep.IDEmpleado = @IDEmpleado AND tee.IDTipoRelacion <> 4 AND tep.IDProyecto = @IDProyecto

	SELECT te.IDEvaluacionEmpleado,te.IDEvaluador,te.ClaveEmpleado,te.NombreCompleto,cast( isnull(sum(tcg.Porcentaje) / count(*),0.00) AS decimal(10,2)) AS Calificacion
	FROM #tempEvaluadores te
		JOIN Evaluacion360.tblCatGrupos tcg	ON tcg.IDReferencia = te.IDEvaluacionEmpleado AND tcg.TipoReferencia = 4
	GROUP BY te.IDEvaluacionEmpleado,te.IDEvaluador,te.ClaveEmpleado,te.NombreCompleto

--	SELECT * FROM Evaluacion360.tblCatGrupos WHERE Evaluacion360.tblCatGrupos.TipoReferencia = 4


	--SELECT * FROM Evaluacion360.tblEstatusEvaluacionEmpleado teee WHERE teee.IDEvaluacionEmpleado = 110081

--	SELECT * FROM Evaluacion360.tblCatProyectos tcp	
GO
