USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Evaluacion360].[spActualizarProgresoProyecto](
	@IDProyecto int  
 	,@IDUsuario int 
)as
	--DECLARE @IDProyecto int = 5
	--	,@IDUsuario int = 1
	--;
	declare
		@IDUsuarioAdmin int
	;

	select @IDUsuarioAdmin = [App].[fnGetConfiguracionGeneral]('IDUsuarioAdmin', @IDUsuario, 1)

	IF object_id('tempdb..#tempInfoEvaProyectos') IS NOT NULL DROP TABLE #tempInfoEvaProyectos;
	IF object_id('tempdb..#tempTotalesProyectos') IS NOT NULL DROP TABLE #tempTotalesProyectos;

	CREATE TABLE #tempInfoEvaProyectos (
		IDEmpleadoProyecto int
		,IDProyecto int
		,IDEmpleado int
		,ClaveEmpleado varchar(20)
		,Colaborador varchar(500)
		,IDEvaluacionEmpleado int
		,IDTipoRelacion int
		,Relacion varchar(255)
		,IDEvaluador int
		,ClaveEvaluador varchar(20)
		,Evaluador varchar(500)
		,Minimo int
		,Maximo int
		,Requerido bit
		,CumpleTipoRelacion bit
		,[Row] int
		,IDEstatusEvaluacionEmpleado int
		,IDEstatus int
		,Estatus varchar(255)
		,Progreso int
		,Iniciales VARCHAR(2)
		,Evaluar bit
	);

	INSERT #tempInfoEvaProyectos
	EXEC [Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] @IDProyecto=@IDProyecto,@IDUsuario = @IDUsuarioAdmin

	delete #tempInfoEvaProyectos
	where IDEvaluacionEmpleado = 0

	SELECT 
		count(*) AS TotalPruebasARealizar 
		,sum(CASE WHEN #tempInfoEvaProyectos.IDEstatus = 13 THEN 1 ELSE 0 end) AS TotalPruebasRealizadas 
		,@IDProyecto AS IDProyecto
	INTO #tempTotalesProyectos
	FROM #tempInfoEvaProyectos 
	WHERE IDEvaluador > 0
	--Requerido = 1

	UPDATE p
	SET
		p.TotalPruebasARealizar	   = tiep.TotalPruebasARealizar
		,p.TotalPruebasRealizadas  = tiep.TotalPruebasRealizadas
		,p.Progreso				   = (tiep.TotalPruebasRealizadas * 100) / tiep.TotalPruebasARealizar
	FROM Evaluacion360.tblCatProyectos p
		JOIN #tempTotalesProyectos tiep	ON p.IDProyecto = tiep.IDProyecto
GO
