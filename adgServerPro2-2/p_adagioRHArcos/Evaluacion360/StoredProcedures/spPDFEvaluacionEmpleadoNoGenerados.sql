USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [Evaluacion360].[spPDFEvaluacionEmpleadoNoGenerados]
AS

	DECLARE @dtProyectos			[Evaluacion360].[dtProyectos]
			, @IDUsuario			INT
			, @IDUsuarioAdmin		INT
			, @EVALUACION_360		INT = 1
			, @EVALUACION_DESEMPENO	INT = 2
			, @EVALUACION_CLIMA		INT = 3
			, @EVALUACION_ENCUESTA	INT = 4
			;  

	SET LANGUAGE 'Spanish';

	IF OBJECT_ID('tempdb..#tempEmpsProyectos') IS NOT NULL DROP TABLE #tempEmpsProyectos;
	IF OBJECT_ID('tempdb..#tempHistorialEstatusEvaluacion') IS NOT NULL DROP TABLE #tempHistorialEstatusEvaluacion;
	IF OBJECT_ID('tempdb..#tempEvaluacionesSinPDFs') IS NOT NULL DROP TABLE #tempEvaluacionesSinPDFs;	


	DECLARE @tblProyectos TABLE
	(
		ID					INT IDENTITY(1,1)
		, IDProyecto		INT
		, TotalPruebas		INT
		, TotalRealizadas	INT
	)

	DECLARE @tblEvaluacionPendientes TABLE
	(
		IDEvaluacionEmpleado			INT
		, IDEmpleadoProyecto			INT
		, IDTipoRelacion				INT
		, Relacion						VARCHAR(MAX)
		, IDEvaluador					INT
		, ClaveEvaluador				VARCHAR(MAX)
		, Evaluador						VARCHAR(MAX)
		, IDProyecto					INT
		, Proyecto						VARCHAR(MAX)
		, IDEmpleado					INT
		, ClaveEmpleado 				VARCHAR(MAX)
		, Colaborador					VARCHAR(MAX)
		, IDEstatusEvaluacionEmpleado	INT
		, IDEstatus						INT
		, Estatus						VARCHAR(MAX)
		, IDUsuario						INT
		, FechaCreacion					DATETIME
		, Progreso 						INT
	);

	

	SELECT TOP 1 @IDUsuario = CAST(Valor AS INT)
	FROM [App].[tblConfiguracionesGenerales]
	WHERE IDConfiguracion = 'IDUsuarioAdmin';
  
	SELECT @IDUsuarioAdmin = CAST(Valor AS INT) 
	FROM [App].[tblConfiguracionesGenerales] WITH (NOLOCK)
	WHERE IDConfiguracion = 'IDUsuarioAdmin';



	INSERT @dtProyectos  
	EXEC [Evaluacion360].[spBuscarProyectos] @IDUsuario = @IDUsuario, @VerTodas = 1;
	--SELECT * FROM @dtProyectos;

	--DELETE FROM @dtProyectos
	--WHERE IDEstatus <> 6 -- 6 = COMPLETO
  
	
	SELECT DISTINCT EP.IDEmpleadoProyecto
			--, EP.IDProyecto
	INTO #tempEmpsProyectos
	FROM [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK)
		INNER JOIN @dtProyectos P ON EP.IDProyecto = P.IDProyecto;
	--SELECT * FROM #tempEmpsProyectos
	
	DELETE EP
	FROM #tempEmpsProyectos EP
		LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE WITH (NOLOCK) ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
	WHERE EE.IDEvaluacionEmpleado IS NULL
	--SELECT * FROM #tempEmpsProyectos


	SELECT EE.*
			, EEE.IDEstatusEvaluacionEmpleado
			, EEE.IDEstatus
			, EEE.IDUsuario
			, EEE.FechaCreacion 
			, ROW_NUMBER() OVER(PARTITION BY EEE.IDEvaluacionEmpleado ORDER BY EEE.IDEstatusEvaluacionEmpleado DESC) AS [ROW]
	INTO #tempHistorialEstatusEvaluacion
	FROM [Evaluacion360].[tblEvaluacionesEmpleados] EE WITH (NOLOCK)
		JOIN #tempEmpsProyectos EP ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
		LEFT JOIN [Evaluacion360].[tblEstatusEvaluacionEmpleado] EEE WITH (NOLOCK) ON EE.IDEvaluacionEmpleado = EEE.IDEvaluacionEmpleado -- AND EEE.IDEstatus = 10
	--SELECT * FROM #tempHistorialEstatusEvaluacion
	
	
	-- ELIMINAMOS LAS PRUEBAS QUE NO ESTAN COMPLETAS
	DELETE TEP
	FROM #tempEmpsProyectos TEP
		JOIN #tempHistorialEstatusEvaluacion TH ON TEP.IDEmpleadoProyecto = TH.IDEmpleadoProyecto -- AND TH.IDEstatus <> 13 -- 13 = COMPLETA
	WHERE TEP.IDEmpleadoProyecto IN (
										SELECT TEP.IDEmpleadoProyecto
										FROM #tempEmpsProyectos TEP
											JOIN #tempHistorialEstatusEvaluacion TH ON TEP.IDEmpleadoProyecto = TH.IDEmpleadoProyecto AND ISNULL(TH.IDEstatus, 0) <> 13 AND TH.[ROW] = 1
									)
	--SELECT * FROM #tempEmpsProyectos;	   	  

	

	/*--------------------------------------------------------------------------------------------------------------------------------------------------*/
	


	-- RESULTADO SOLO PARA EVALUACIONES 360
	
	SELECT EP.*	
	FROM #tempEmpsProyectos P
		JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
		JOIN [Evaluacion360].[tblCatProyectos] P2 ON EP.IDProyecto = P2.IDProyecto
	WHERE ISNULL(EP.PDFGenerado, CAST(0 AS BIT)) = 0
			AND P2.IDTipoProyecto = @EVALUACION_360
	ORDER BY EP.IDProyecto;
	
	SELECT DISTINCT EP.IDProyecto			
	FROM #tempEmpsProyectos P
		JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
		JOIN [Evaluacion360].[tblCatProyectos] P2 ON EP.IDProyecto = P2.IDProyecto
	WHERE ISNULL(EP.PDFGenerado, CAST(0 AS BIT)) = 0
			AND P2.IDTipoProyecto = @EVALUACION_360
	ORDER BY EP.IDProyecto;
GO
