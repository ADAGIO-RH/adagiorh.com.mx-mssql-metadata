USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Evaluacion360].[spAsginarEmpleadosAProyecto](
	@IDProyecto INT,
	@IDUsuario INT
) AS

	DECLARE @dtFiltros [Nomina].[dtFiltrosRH],
			@empleados [RH].[dtEmpleados],
			@i INT = 0,
			@fecha DATE = GETDATE(),
			@Catalogo VARCHAR(255),
			@OrdenFiltro INT,
			@EnviarResultadoPruebasAColaboradores NVARCHAR(100) = 'false';
		
	
	IF EXISTS(SELECT TOP 1 1 FROM [Evaluacion360].[tblConfiguracionAvanzadaProyecto] WITH (NOLOCK)
							 WHERE IDProyecto = @IDProyecto AND IDConfiguracionAvanzada = 12) -- ENVIAR RESULTADO DE LAS PRUEBAS A LOS COLABORADORES
	BEGIN
		SELECT @EnviarResultadoPruebasAColaboradores = ISNULL(Valor, 'false')
		FROM [Evaluacion360].[tblConfiguracionAvanzadaProyecto] WITH(NOLOCK)
		WHERE IDProyecto = @IDProyecto AND IDConfiguracionAvanzada = 12
	END;
		

	IF OBJECT_ID('tempdb..#tempFinalEmpleados') IS NOT NULL DROP TABLE #tempFinalEmpleados;
	IF OBJECT_ID('tempdb..#tempFiltrosAsignarEmpAProyecto') IS NOT NULL DROP TABLE #tempFiltrosAsignarEmpAProyecto;


	CREATE TABLE #tempFinalEmpleados(IDEmpleado INT, TipoFiltro VARCHAR(255) COLLATE database_default, OrdenFiltro INT)


	-- OBTIENE LOS FILTROS
	SELECT F.*, S.Orden
	INTO #tempFiltrosAsignarEmpAProyecto
	FROM [Evaluacion360].[tblFiltrosProyectos] F WITH (NOLOCK)
		JOIN Seguridad.tblCatTiposFiltros S ON F.TipoFiltro = S.Filtro
	WHERE F.IDProyecto = @IDProyecto --AND F.TipoFiltro <> 'Excluir Empleado'
	



	SELECT @i = MIN(IDFiltroProyecto) FROM #tempFiltrosAsignarEmpAProyecto

	WHILE EXISTS(SELECT TOP 1 1 FROM #tempFiltrosAsignarEmpAProyecto WHERE IDFiltroProyecto >= @i)
	BEGIN

		DELETE FROM @dtFiltros;
		DELETE FROM @empleados;

		INSERT INTO @dtFiltros(Catalogo, Value)
		SELECT CASE 
				WHEN TipoFiltro = 'Empleados' OR TipoFiltro = 'Excluir Empleado'
					THEN 'Empleados'
					ELSE TipoFiltro
				END,
				ID
		FROM #tempFiltrosAsignarEmpAProyecto
		WHERE IDFiltroProyecto = @i


		SELECT @Catalogo= CASE 
							WHEN TipoFiltro = 'Empleados' OR TipoFiltro = 'Excluir Empleado'
								THEN TipoFiltro
								ELSE COALESCE(TipoFiltro, '') + ' | ' + COALESCE(Descripcion, '')
							END,
				@OrdenFiltro = Orden
		FROM #tempFiltrosAsignarEmpAProyecto
		WHERE IDFiltroProyecto = @i
		

		INSERT INTO @empleados
		EXEC [RH].[spBuscarEmpleados] @FechaIni	= @fecha,
									  @Fechafin	= @fecha,
									  @IDUsuario = @IDUsuario,
									  @dtFiltros = @dtFiltros

		INSERT #tempFinalEmpleados
		SELECT IDEmpleado, @Catalogo, @OrdenFiltro FROM @empleados


		SELECT @i = MIN(IDFiltroProyecto) FROM #tempFiltrosAsignarEmpAProyecto WHERE IDFiltroProyecto > @i
	
	END;


	-- CTE QUE ELIMINA LOS COLABORADORES DUPLICADOS
	;WITH TempEmp (IDEmpleado,duplicateRecCount)
	AS
	(
		SELECT IDEmpleado, ROW_NUMBER() OVER(PARTITION BY IDEmpleado ORDER BY OrdenFiltro) AS duplicateRecCount
		FROM #tempFinalEmpleados 
		--WHERE TipoFiltro IN ('Empleados', 'Excluir Empleado')
	)


	-- NOW DELETE DUPLICATE RECORDS
	DELETE FROM TempEmp
	WHERE duplicateRecCount > 1 ;
	
	-- RESULTADO FINAL
	--SELECT * FROM #tempFinalEmpleados ORDER BY TipoFiltro
	--RETURN



	BEGIN TRY
		BEGIN TRAN TransFiltrosProyecto
			MERGE [Evaluacion360].[tblEmpleadosProyectos] AS TARGET
			USING #tempFinalEmpleados AS SOURCE
				ON TARGET.IDEmpleado = SOURCE.IDEmpleado AND TARGET.IDProyecto = @IDProyecto
			WHEN MATCHED THEN
				UPDATE
					SET TARGET.TipoFiltro = SOURCE.TipoFiltro
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDProyecto, IDEmpleado, TipoFiltro)
				VALUES(@IDProyecto, SOURCE.IDEmpleado, SOURCE.TipoFiltro)
			WHEN NOT MATCHED BY SOURCE AND (TARGET.IDProyecto = @IDProyecto) THEN 
			DELETE ;
		COMMIT TRAN TransFiltrosProyecto
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE(),
			   ERROR_LINE()
		ROLLBACK TRAN TransFiltrosProyecto
	END CATCH


	   
	IF EXISTS(SELECT TOP 1 1 FROM [Evaluacion360].[tblEvaluadoresRequeridos] WITH (NOLOCK) WHERE IDProyecto = @IDProyecto AND IDTipoRelacion = 4) 
		BEGIN
		
			DECLARE @archive TABLE (
				ActionType VARCHAR(50),
				IDEvaluacionEmpleado INT
			);

			BEGIN TRY
				BEGIN TRAN TransEvaEmpProyecto
					MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
					USING (SELECT *
						   FROM [Evaluacion360].[tblEmpleadosProyectos]
						   WHERE IDProyecto = @IDProyecto 
						  ) AS SOURCE
						ON TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto AND 
						   TARGET.IDTipoRelacion = 4 /* 4 = a AutoEvaluación */			
					WHEN NOT MATCHED BY TARGET THEN 
						INSERT(IDEmpleadoProyecto, IDTipoRelacion, IDEvaluador)
						VALUES(SOURCE.IDEmpleadoProyecto, 4, SOURCE.IDEmpleado)
					WHEN NOT MATCHED BY SOURCE AND TARGET.IDTipoRelacion = 4 AND TARGET.IDEmpleadoProyecto IN (SELECT IDEmpleadoProyecto FROM Evaluacion360.[tblEmpleadosProyectos] WHERE IDProyecto = @IDProyecto) THEN
					DELETE
					OUTPUT
				   $action AS ActionType,
				   inserted.IDEvaluacionEmpleado
				   INTO @archive;
				   COMMIT TRAN TransEvaEmpProyecto			
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE(),
				ERROR_LINE(),
				'KLK' AS DameLU,
				@IDProyecto AS IDProyecto
				ROLLBACK TRAN TransEvaEmpProyecto
			END CATCH

			INSERT [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado, IDEstatus, IDUsuario)
			SELECT em.IDEvaluacionEmpleado, 11, @IDUsuario
			FROM [Evaluacion360].[tblEmpleadosProyectos] ep WITH (NOLOCK)
				JOIN [Evaluacion360].[tblEvaluacionesEmpleados] em WITH (NOLOCK) ON ep.IDEmpleadoProyecto = em.IDEmpleadoProyecto
			WHERE ep.IDProyecto = @IDProyecto AND 
				  em.IDTipoRelacion = 4 AND
				  em.IDEvaluacionEmpleado NOT IN (SELECT IDEvaluacionEmpleado FROM [Evaluacion360].[tblEstatusEvaluacionEmpleado])
		END
	ELSE
		BEGIN
			DELETE ee
			FROM [Evaluacion360].[tblEvaluacionesEmpleados] ee
				INNER JOIN [Evaluacion360].[tblEmpleadosProyectos] ep ON ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
			WHERE ep.IDProyecto = @IDProyecto AND 
				  ee.IDTipoRelacion = 4
		END;


	-- SE CREA EL REGISTRO DEL COLABORADOR PARA SEGUN LA CONFIGURACION DEL PROYECTO PARA ENVIAR O NO LOS RESULTADOS A LOS COLABORADORES.
	MERGE [Evaluacion360].[tblEnviarResultadosAColaboradores] AS TARGET
	USING [Evaluacion360].[tblEmpleadosProyectos] AS SOURCE
	ON TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto
	--WHEN MATCHED THEN
	--	UPDATE 
	--		SET TARGET.Valor = CASE WHEN LOWER(@EnviarResultadoPruebasAColaboradores) = 'true' THEN 0 ELSE 1 END
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(IDEmpleadoProyecto, Valor)
		VALUES(SOURCE.IDEmpleadoProyecto, CASE WHEN LOWER(@EnviarResultadoPruebasAColaboradores) = 'true' THEN 0 ELSE 1 END);


	EXEC [Evaluacion360].[spActualizarProgresoProyecto] @IDProyecto = @IDProyecto,
														@IDUsuario = @IDUsuario
GO
