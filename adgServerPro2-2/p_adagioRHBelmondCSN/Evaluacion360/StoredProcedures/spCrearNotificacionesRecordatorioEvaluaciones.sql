USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [Evaluacion360].[spCrearNotificacionesRecordatorioEvaluaciones] 
AS
	BEGIN

		DECLARE @IDProyecto					INT = 0
				, @IDUsuario				INT
				, @FechaInicio				DATE
				, @FechaFin					DATE
				, @Today					DATE = GETDATE()
				, @TotalDias				INT
				, @DiasRestantes			INT
				, @PorcetajeDiasRestantes	INT
				, @IDEvaluador				INT
				, @dtProyectos				[Evaluacion360].[dtProyectos]
				;

		SELECT @IDUsuario = CAST(ISNULL(valor, 0) AS INT) FROM [App].[tblConfiguracionesGenerales] WHERE IDConfiguracion = 'IDUsuarioAdmin';
	 
		IF OBJECT_ID('tempdb..##evaluacionPendientesRec') IS NOT NULL DROP TABLE ##evaluacionPendientesRec;
		IF OBJECT_ID('tempdb..##evaluacionPendientesPorEvaluador') IS NOT NULL DROP TABLE ##evaluacionPendientesPorEvaluador;

		CREATE TABLE ##evaluacionPendientesRec(
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

		CREATE TABLE ##evaluacionPendientesPorEvaluador(
			IDEvaluador						INT
			, ContEvaluacionesPendientes	INT
		);

		INSERT @dtProyectos
		EXEC [Evaluacion360].[spBuscarProyectos] @IDUsuario = @IDUsuario;

		DELETE @dtProyectos WHERE IDEstatus <> 3;
		--DELETE @dtProyectos WHERE IDProyecto NOT IN(158);

		SELECT * FROM @dtProyectos
		
		SELECT @IDProyecto = MIN(IDProyecto) FROM @dtProyectos P;

		WHILE EXISTS (SELECT TOP 1 1 FROM @dtProyectos TP WHERE TP.IDProyecto >= @IDProyecto)
		BEGIN
		
			DELETE ##evaluacionPendientesRec;
			DELETE ##evaluacionPendientesPorEvaluador;
			-- PRINT @IDProyecto;

			SELECT @FechaInicio = TP.FechaInicio
					, @FechaFin = TP.FechaFin
			FROM @dtProyectos TP
			WHERE TP.IDProyecto = @IDProyecto;


			IF (@Today BETWEEN @FechaInicio AND @FechaFin)
			BEGIN
				
				SELECT @TotalDias = DATEDIFF(DAY, @FechaInicio, @FechaFin);
				--SELECT @TotalDias;

				SELECT @DiasRestantes = DATEDIFF(DAY, @Today, @FechaFin);

				-- EVITA DIVISION POR CERO Y DEVUELVE 8 CUANDO @TotalDias ES 0
				SELECT @PorcetajeDiasRestantes = 
					CASE
						WHEN @TotalDias = 0
							THEN 8
							ELSE (@DiasRestantes * 100) / @TotalDias
						END;
				--SELECT @PorcetajeDiasRestantes


				-- EVALUACIONES PENDIENTES
				INSERT ##evaluacionPendientesRec
				EXEC [Evaluacion360].[spBuscarPruebasPorProyecto] @IDProyecto = @IDProyecto, @Tipo = 1, @IDUsuario = @IDUsuario;

				-- EVALUADORES Y NUMERO DE EVALUACIONES PENDIENTES
				INSERT ##evaluacionPendientesPorEvaluador
				SELECT T2.IDEvaluador
						, T2.ContEvaluacionesPendientes
				FROM (SELECT T1.IDEvaluador, COUNT(T1.IDEvaluador) AS ContEvaluacionesPendientes  FROM ##evaluacionPendientesRec T1 GROUP BY T1.IDEvaluador) T2
				ORDER BY T2.ContEvaluacionesPendientes


				/*-----------------------------------------------------------------------------------------------------------------------------------*/
				
				IF(
					(@PorcetajeDiasRestantes BETWEEN 45 AND 55) -- 55
					AND EXISTS(SELECT TOP 1 1 FROM ##evaluacionPendientesRec EP)
					AND NOT EXISTS(SELECT TOP 1 1 FROM [Evaluacion360].[tblRecordarioEnviadosPorProyecto] WHERE IDProyecto = @IDProyecto AND IDTipoRecordatorio = 1)
				)
				BEGIN
				
					SELECT @IDEvaluador = MIN(IDEvaluador) FROM ##evaluacionPendientesPorEvaluador EP;

					WHILE EXISTS(SELECT TOP 1 1 FROM ##evaluacionPendientesPorEvaluador EP WHERE EP.IDEvaluador >= @IDEvaluador)
						BEGIN						
							
							EXEC [Evaluacion360].[spITareaDeRecordatorioEnEvaluacion] @IsGeneral = 1, @IDProyecto = @IDProyecto, @IDEvaluacionEmpleado = 0, @IDEvaluador = @IDEvaluador, @IDUsuario = @IDUsuario;
							SELECT @IDEvaluador = MIN(IDEvaluador) FROM ##evaluacionPendientesPorEvaluador EP WHERE EP.IDEvaluador > @IDEvaluador;
							
						END;

					INSERT INTO [Evaluacion360].[tblRecordarioEnviadosPorProyecto](IDProyecto,IDTipoRecordatorio)
					SELECT @IDProyecto, 1;
				END;

				/*-----------------------------------------------------------------------------------------------------------------------------------*/

				IF(
					(@PorcetajeDiasRestantes BETWEEN 30 AND 35) --35
					AND EXISTS(SELECT TOP 1 1 FROM ##evaluacionPendientesRec EP)
					AND NOT EXISTS(SELECT TOP 1 1 FROM  Evaluacion360.tblRecordarioEnviadosPorProyecto WHERE IDProyecto = @IDProyecto AND IDTipoRecordatorio = 2)
				)
				BEGIN
				
					SELECT @IDEvaluador = MIN(IDEvaluador) FROM ##evaluacionPendientesPorEvaluador EP;

					WHILE EXISTS(SELECT TOP 1 1 FROM ##evaluacionPendientesPorEvaluador EP WHERE EP.IDEvaluador >= @IDEvaluador)
						BEGIN						
							
							EXEC [Evaluacion360].[spITareaDeRecordatorioEnEvaluacion] @IsGeneral = 1, @IDProyecto = @IDProyecto, @IDEvaluacionEmpleado = 0, @IDEvaluador = @IDEvaluador, @IDUsuario = @IDUsuario;
							SELECT @IDEvaluador = MIN(IDEvaluador) FROM ##evaluacionPendientesPorEvaluador EP WHERE EP.IDEvaluador > @IDEvaluador;
							
						END;

					INSERT INTO [Evaluacion360].[tblRecordarioEnviadosPorProyecto](IDProyecto, IDTipoRecordatorio)
					SELECT @IDProyecto, 2;
				END;

				/*-----------------------------------------------------------------------------------------------------------------------------------*/

				SELECT @IDProyecto AS IDProyecto, @PorcetajeDiasRestantes AS PorcetajeDiasRestantes;
				
				IF (
					(@PorcetajeDiasRestantes BETWEEN 8 AND 12) -- 12
					AND EXISTS(SELECT TOP 1 1 FROM ##evaluacionPendientesRec EP)
					AND NOT EXISTS(SELECT TOP 1 1 FROM [Evaluacion360].[tblRecordarioEnviadosPorProyecto] WHERE IDProyecto = @IDProyecto AND IDTipoRecordatorio = 3)
				)
				BEGIN
				
					SELECT @IDEvaluador = MIN(IDEvaluador) FROM ##evaluacionPendientesPorEvaluador EP;

					WHILE EXISTS(SELECT TOP 1 1 FROM ##evaluacionPendientesPorEvaluador EP WHERE EP.IDEvaluador >= @IDEvaluador)
						BEGIN						
							
							EXEC [Evaluacion360].[spITareaDeRecordatorioEnEvaluacion] @IsGeneral = 1, @IDProyecto = @IDProyecto, @IDEvaluacionEmpleado = 0, @IDEvaluador = @IDEvaluador, @IDUsuario = @IDUsuario;
							SELECT @IDEvaluador = MIN(IDEvaluador) FROM ##evaluacionPendientesPorEvaluador EP WHERE EP.IDEvaluador > @IDEvaluador;
							
						END;

					INSERT INTO [Evaluacion360].[tblRecordarioEnviadosPorProyecto](IDProyecto, IDTipoRecordatorio)
					SELECT @IDProyecto, 3;
				END;
			
			END;

			SELECT @IDProyecto = MIN(IDProyecto) FROM @dtProyectos P WHERE P.IDProyecto > @IDProyecto;

		END; 

		-- SELECT * FROM [Evaluacion360].[tblCatEstatus] TCE

	END
GO
