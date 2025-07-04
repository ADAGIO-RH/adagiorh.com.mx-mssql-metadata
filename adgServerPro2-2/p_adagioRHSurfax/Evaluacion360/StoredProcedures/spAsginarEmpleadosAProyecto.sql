USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Evaluacion360].[spAsginarEmpleadosAProyecto](
	@IDProyecto INT,
	@IDUsuario INT
) AS

	DECLARE 
		@dtFiltros [Nomina].[dtFiltrosRH],
		@empleados [RH].[dtEmpleados],
		@i INT = 0,
		@fecha DATE = GETDATE(),
		@Catalogo VARCHAR(255),
		@OrdenFiltro INT,
		@EnviarResultadoPruebasAColaboradores NVARCHAR(100) = 'false',
		@IDTipoProyecto int,
		@TIPO_EVALUACION_GENERAL int = -1,
		@ID_TIPO_PROYECTO_EVALUACION_360 int = 1,
		@ID_TIPO_PROYECTO_DESEMPENIO int = 2,

		@ID_TIPO_RELACION_JEFE_DIRECTO int = 1,
		@ID_TIPO_RELACION_AUTOEVALUACION int = 4
	;
	
	select @IDTipoProyecto = isnull(IDTipoProyecto, @ID_TIPO_PROYECTO_EVALUACION_360)
	from Evaluacion360.tblCatProyectos
	where IDProyecto = @IDProyecto
	
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


		/* ******************************************
			UTILIZAR PARA PRUEBAS
		*/
		--INSERT INTO @empleados
		--SELECT * FROM [RH].[tblEmpleadosMaster] WHERE IDEmpleado IN (72, 1279)
		-- ******************************************
		
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
			WHEN NOT MATCHED BY SOURCE AND (TARGET.IDProyecto = @IDProyecto) AND (TARGET.IDEmpleado in (select IDEmpleado from Seguridad.tblDetalleFiltrosEmpleadosUsuarios where IDUsuario = @IDUsuario)) THEN 
			DELETE ;
		COMMIT TRAN TransFiltrosProyecto
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE(),
			   ERROR_LINE()
		ROLLBACK TRAN TransFiltrosProyecto
	END CATCH
	
	
	   
	IF EXISTS(
		SELECT TOP 1 1 
		FROM [Evaluacion360].[tblEvaluadoresRequeridos] WITH (NOLOCK) 
		WHERE IDProyecto = @IDProyecto AND IDTipoRelacion = @ID_TIPO_RELACION_AUTOEVALUACION
	) 
	BEGIN
		
		DECLARE @archive TABLE (
			ActionType VARCHAR(50),
			IDEvaluacionEmpleado INT
		);
		
		BEGIN TRY
			BEGIN TRAN TransEvaEmpProyecto
					
				IF (@IDTipoProyecto = @ID_TIPO_PROYECTO_DESEMPENIO)
					BEGIN
						MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
						USING (
							select 
								ep.*,
								te.IDTipoEvaluacion,
								JSON_VALUE(te.Traduccion, '$.esmx.Nombre') as TipoEva
							from Evaluacion360.tblEmpleadosProyectos ep
								cross apply Evaluacion360.tblCatTiposEvaluaciones te 
							where IDProyecto = @IDProyecto and te.IDTipoEvaluacion != @TIPO_EVALUACION_GENERAL 
						) AS SOURCE
							ON TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto AND 
								TARGET.IDTipoEvaluacion = SOURCE.IDTipoEvaluacion  and
								TARGET.IDTipoRelacion = @ID_TIPO_RELACION_AUTOEVALUACION
						WHEN NOT MATCHED BY TARGET THEN 
							INSERT(IDEmpleadoProyecto, IDTipoRelacion, IDEvaluador, IDTipoEvaluacion)
							VALUES(SOURCE.IDEmpleadoProyecto, @ID_TIPO_RELACION_AUTOEVALUACION, SOURCE.IDEmpleado, SOURCE.IDTipoEvaluacion)
						WHEN NOT MATCHED BY SOURCE AND TARGET.IDTipoRelacion = @ID_TIPO_RELACION_AUTOEVALUACION AND TARGET.IDEmpleadoProyecto IN (SELECT IDEmpleadoProyecto FROM Evaluacion360.[tblEmpleadosProyectos] WHERE IDProyecto = @IDProyecto) THEN
						DELETE
						OUTPUT
						$action AS ActionType,
						inserted.IDEvaluacionEmpleado
						INTO @archive;	
					END
				ELSE
					BEGIN				
						MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
						USING (SELECT *
								FROM [Evaluacion360].[tblEmpleadosProyectos]
								WHERE IDProyecto = @IDProyecto 
								) AS SOURCE
							ON TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto AND 
								TARGET.IDTipoRelacion = @ID_TIPO_RELACION_AUTOEVALUACION
						WHEN NOT MATCHED BY TARGET THEN 
							INSERT(IDEmpleadoProyecto, IDTipoRelacion, IDEvaluador)
							VALUES(SOURCE.IDEmpleadoProyecto, @ID_TIPO_RELACION_AUTOEVALUACION, SOURCE.IDEmpleado)
						WHEN NOT MATCHED BY SOURCE AND TARGET.IDTipoRelacion = @ID_TIPO_RELACION_AUTOEVALUACION AND TARGET.IDEmpleadoProyecto IN (SELECT IDEmpleadoProyecto FROM Evaluacion360.[tblEmpleadosProyectos] WHERE IDProyecto = @IDProyecto) THEN
						DELETE
						OUTPUT
						$action AS ActionType,
						inserted.IDEvaluacionEmpleado
						INTO @archive;
					END
				COMMIT TRAN TransEvaEmpProyecto			
		END TRY
		BEGIN CATCH
			SELECT 
				ERROR_MESSAGE(),
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
				em.IDTipoRelacion = @ID_TIPO_RELACION_AUTOEVALUACION AND
				em.IDEvaluacionEmpleado NOT IN (SELECT IDEvaluacionEmpleado FROM [Evaluacion360].[tblEstatusEvaluacionEmpleado])
	END
	ELSE
	BEGIN
		DELETE ee
		FROM [Evaluacion360].[tblEvaluacionesEmpleados] ee
			INNER JOIN [Evaluacion360].[tblEmpleadosProyectos] ep ON ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		WHERE ep.IDProyecto = @IDProyecto AND 
				ee.IDTipoRelacion = @ID_TIPO_RELACION_AUTOEVALUACION
	END;

	if (@IDTipoProyecto = @ID_TIPO_PROYECTO_DESEMPENIO)
	begin
		DECLARE @archiveTipo2 TABLE (
			ActionType VARCHAR(50),
			IDEvaluacionEmpleado INT
		);
		BEGIN TRY
			BEGIN TRAN TransEvaEmpProyecto
				MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
				USING (
					SELECT 
						EP.*,
						TE.IDTipoEvaluacion,
						JSON_VALUE(TE.Traduccion, '$.esmx.Nombre') AS TipoEva,
						(SELECT TOP 1 JE.IDJefe 
							FROM [RH].[tblJefesEmpleados] JE 
							JOIN [RH].[tblEmpleadosMaster] EM ON JE.IDJefe = EM.IDEmpleado
							WHERE JE.IDEmpleado = EP.IDEmpleado AND
								EM.Vigente = 1
						ORDER BY FechaReg DESC) AS IDJefe
					FROM [Evaluacion360].[tblEmpleadosProyectos] EP
						CROSS APPLY [Evaluacion360].[tblCatTiposEvaluaciones] TE
					WHERE IDProyecto = @IDProyecto  and te.IDTipoEvaluacion != @TIPO_EVALUACION_GENERAL
				) AS SOURCE
					ON TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto AND 
						TARGET.IDTipoEvaluacion = SOURCE.IDTipoEvaluacion and
						TARGET.IDTipoRelacion = @ID_TIPO_RELACION_JEFE_DIRECTO
				WHEN NOT MATCHED BY TARGET THEN 
					INSERT(IDEmpleadoProyecto, IDTipoRelacion, IDEvaluador, IDTipoEvaluacion)
					VALUES(SOURCE.IDEmpleadoProyecto, 1, SOURCE.IDJefe, SOURCE.IDTipoEvaluacion)
				WHEN NOT MATCHED BY SOURCE 
						AND TARGET.IDTipoRelacion = @ID_TIPO_RELACION_JEFE_DIRECTO 
						AND TARGET.IDEmpleadoProyecto IN (SELECT IDEmpleadoProyecto 
														FROM Evaluacion360.[tblEmpleadosProyectos] 
														WHERE IDProyecto = @IDProyecto) THEN
				DELETE
				OUTPUT
				$action AS ActionType,
				inserted.IDEvaluacionEmpleado
				INTO @archiveTipo2;

				INSERT [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado, IDEstatus, IDUsuario)
				SELECT em.IDEvaluacionEmpleado, 11, @IDUsuario
				FROM [Evaluacion360].[tblEmpleadosProyectos] ep WITH (NOLOCK)
					JOIN [Evaluacion360].[tblEvaluacionesEmpleados] em WITH (NOLOCK) ON ep.IDEmpleadoProyecto = em.IDEmpleadoProyecto
				WHERE ep.IDProyecto = @IDProyecto AND 
						em.IDEvaluacionEmpleado NOT IN (SELECT IDEvaluacionEmpleado FROM [Evaluacion360].[tblEstatusEvaluacionEmpleado])
		
			COMMIT TRAN TransEvaEmpProyecto			
		END TRY
		BEGIN CATCH
			SELECT 
				ERROR_MESSAGE(),
				ERROR_LINE(),
				@IDProyecto AS IDProyecto
			ROLLBACK TRAN TransEvaEmpProyecto
		END CATCH
		
	end


	-- SE CREA EL REGISTRO DEL COLABORADOR PARA SEGUN LA CONFIGURACION DEL PROYECTO PARA ENVIAR O NO LOS RESULTADOS A LOS COLABORADORES.
	MERGE [Evaluacion360].[tblEnviarResultadosAColaboradores] AS TARGET
	USING [Evaluacion360].[tblEmpleadosProyectos] AS SOURCE
	ON TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto
	--WHEN MATCHED THEN
	--	UPDATE 
	--		SET TARGET.Valor = CASE WHEN LOWER(@EnviarResultadoPruebasAColaboradores) = 'true' THEN 0 ELSE 1 END
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(IDEmpleadoProyecto, Valor)
		VALUES(SOURCE.IDEmpleadoProyecto, CASE WHEN LOWER(@EnviarResultadoPruebasAColaboradores) = 'true' THEN 1 ELSE 0 END);

	

	DELETE FROM Evaluacion360.tblEvaluacionesEmpleados
		WHERE IDEvaluacionEmpleado IN 
		(
			SELECT EE.IDEvaluacionEmpleado						   
			FROM Evaluacion360.tblCatProyectos P
				LEFT JOIN Evaluacion360.tblEmpleadosProyectos EP ON P.IDProyecto = EP.IDProyecto
				LEFT JOIN RH.tblEmpleadosMaster E ON EP.IDEmpleado = E.IDEmpleado
				LEFT JOIN Evaluacion360.tblEvaluacionesEmpleados EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
			WHERE P.IDProyecto = @IDProyecto AND
					EP.TipoFiltro = 'Excluir Empleado'
		);

	EXEC [Evaluacion360].[spActualizarProgresoProyecto] @IDProyecto = @IDProyecto,
														@IDUsuario = @IDUsuario
GO
