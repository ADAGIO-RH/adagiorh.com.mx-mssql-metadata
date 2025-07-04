USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Asigna de forma automática evaluadores en una prueba
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019--06-27
** Paremetros		:              

** DataTypes Relacionados: 

exec [Evaluacion360].[spAsignacionAutomaticaEvaluadores] @IDUsuario=1, @IDProyecto=53,@SoloRequeridas=0
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2022-10-06			Alejandro Paredes	Asignar posibles evaluadores automaticamente sin tomar en cuenta el historial
***************************************************************************************************/

CREATE PROC [Evaluacion360].[spAsignacionAutomaticaEvaluadores] (
	@IDUsuario		INT,
	@IDProyecto		INT,
	@SoloRequeridas BIT = 0
) AS
	
	DECLARE @OldJSON  VARCHAR(MAX) = '',
			@NewJSON  VARCHAR(MAX),
			@NombreSP VARCHAR(MAX) = '[Evaluacion360].[spAsignacionAutomaticaEvaluadores]',
			@Tabla	  VARCHAR(MAX) = '[Evaluacion360].[tblEvaluacionesEmpleados]',
			@Accion	  VARCHAR(20)	= 'ASIGNACIÓN AUTOMÁTICA EVALUADORES',
			@Mensaje  VARCHAR(MAX),
			@InformacionExtra VARCHAR(MAX)
	;


	BEGIN TRY
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
	END TRY
	BEGIN CATCH
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
	END CATCH


	SELECT @InformacionExtra = a.JSON 
	FROM (
			SELECT IDProyecto,
				   Nombre,
				   Descripcion,
				   FORMAT(ISNULL(FechaCreacion, GETDATE()), 'dd/MM/yyyy') AS FechaCreacion,
				   Progreso,
				   @SoloRequeridas AS SoloPruebasRequeridas
			FROM Evaluacion360.tblCatProyectos
			WHERE IDProyecto = @IDProyecto
	) B
	CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT B.* FOR XML RAW))) A

	
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		  = @IDUsuario,
		@Tabla			  = @Tabla,
		@Procedimiento	  = @NombreSP,
		@Accion			  = @Accion,
		@NewData		  = @NewJSON,
		@OldData		  = @OldJSON,
		@Mensaje		  = @Mensaje,
		@InformacionExtra = @InformacionExtra


	DECLARE @RelacionesProyecto Evaluacion360.dtRelacionesProyecto
	--TABLE(		
	--	IDEmpleadoProyecto INT,
	--	IDProyecto INT,
	--	IDEmpleado INT,
	--	ClaveEmpleado VARCHAR(20),
	--	Colaborador VARCHAR(254),
	--	IDEvaluacionEmpleado INT,
	--	IDTipoRelacion INT,
	--	Relacion VARCHAR(100),
	--	IDEvaluador INT,
	--	ClaveEvaluador VARCHAR(20),
	--	Evaluador  VARCHAR(100),
	--	Minimo INT,
	--	Maximo INT,
	--	Requerido BIT,
	--	Evaluar BIT,
	--	TotalPaginas INT,
	--	TotalRows INT
	--);

	DECLARE @archive TABLE (
		ActionType VARCHAR(50),
		IDEvaluacionEmpleado INT
	);

	DECLARE @EmpleadoRelacion TABLE (
		ID INT IDENTITY(1, 1),
		IDEmpleado INT,
		IDTipoRelacion INT
	);

	DECLARE @dtInfoOrganigrama RH.dtInfoOrganigrama;
	
	DECLARE @dtInfoOrganigramaAux TABLE(
		IDEmpleadoAEvaluar INT,
		IDJefeEmpleado INT,
		IDEmpleado INT,
		ClaveEmpleado VARCHAR(20),
		Empleado VARCHAR(100),
		PuestoEmpleado VARCHAR(100),
		IDJefe INT,
		ClaveJefe VARCHAR(20),
		Jefe VARCHAR(100),
		PuestoJefe VARCHAR(100),
		IDTipoRelacion INT
	)

	DECLARE @RelacionesProyectoAux TABLE(
		ID INT IDENTITY(1, 1),
		IDEmpleadoProyecto INT,
		IDProyecto INT,
		IDEmpleado INT,
		ClaveEmpleado VARCHAR(20),
		Colaborador VARCHAR(254),
		IDEvaluacionEmpleado INT,
		IDTipoRelacion INT,
		Relacion VARCHAR(100),
		IDEvaluador INT,
		ClaveEvaluador VARCHAR(20),
		Evaluador  VARCHAR(100),
		Minimo INT,
		Maximo INT,
		Requerido BIT,
		Evaluar BIT,
		TotalPaginas INT,
		TotalRows INT,
		RN INT
	)

	IF OBJECT_ID('tempdb..#tempEvaluadores') IS NOT NULL DROP TABLE #tempEvaluadores;
	IF OBJECT_ID('tempdb..#tempHistorialEvaluadores') IS NOT NULL DROP TABLE #tempHistorialEvaluadores;
	IF OBJECT_ID('tempdb..#tempHistorialEvaluadoresAux') IS NOT NULL DROP TABLE #tempHistorialEvaluadoresAux;
	IF OBJECT_ID('tempdb..#tempRelacionesProyecto') IS NOT NULL DROP TABLE #tempRelacionesProyecto;	
	
	
	-- OBTIENE LAS RELACIONES DEL PROYECTO (EJ. SUPERVISOR, COLEGA, COLEGA... ETC)
	INSERT @RelacionesProyecto
	EXEC [Evaluacion360].[spBuscarRelacionesProyecto]
		@IDProyecto = @IDProyecto,
		@IDUsuario = @IDUsuario


	-- ELIMINA LAS RELACIONES DE TIPO AUTOEVALUACION
	DELETE @RelacionesProyecto 
	WHERE IDTipoRelacion = 4 -- (4- AUTOEVALUACION)


	-- ELIMINA LAS RELACIONES QUE NO SON REQUERIDAS EN CASO DE QUE LA VARIABLE @SoloRequeridas ESTE EN 1
	IF(ISNULL(@SoloRequeridas, 0) = 1) 
	BEGIN

		--DELETE EP
		--FROM @RelacionesProyecto RP
		--	RIGHT JOIN Evaluacion360.tblEvaluacionesEmpleados EP ON RP.IDEvaluacionEmpleado = EP.IDEvaluacionEmpleado AND
		--													  RP.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
		--WHERE ISNULL(RP.Requerido, 0) = 0 AND
		--	  EP.IDTipoRelacion != 4
		
		DELETE @RelacionesProyecto WHERE ISNULL(Requerido, 0) = 0

	END


	-- OBTIENE LOS COLABORADORES A EVALUAR Y LAS RELACIONES QUE TIENE (EJ. SUPERVISOR, SUBORDINADO, COLEGA.. ETC)
	INSERT INTO @EmpleadoRelacion
	SELECT IDEmpleado, 
		   IDTipoRelacion 
	FROM @RelacionesProyecto
	WHERE IDEvaluador = 0
	GROUP BY IDEmpleado, IDTipoRelacion


	-- OBTIENE EL DETALLE DE LAS RELACIONES DE LOS COLABORADORES A EVALUAR
	DECLARE @TotalER INT = 0;
	SELECT @TotalER = COUNT(*) FROM @EmpleadoRelacion
	DECLARE @Cont INT = 1;

	WHILE(@Cont <= @TotalER) BEGIN
		
		DELETE @dtInfoOrganigrama
		DECLARE @IDEmpleado INT = 0;
		DECLARE @IDTipoRelacion INT = 0;

		SELECT @IDEmpleado = IDEmpleado, @IDTipoRelacion = IDTipoRelacion FROM @EmpleadoRelacion WHERE ID = @Cont;

		INSERT @dtInfoOrganigrama
		EXEC [RH].[spBuscarInfoOrganigramaEmpleado]
			@IDEmpleado = @IDEmpleado,
			@IDTipoRelacion = @IDTipoRelacion,
			@IDUsuario = 1

		INSERT @dtInfoOrganigramaAux(IDEmpleadoAEvaluar, IDEmpleado, Empleado, IDJefe, Jefe, IDTipoRelacion)
		SELECT @IDEmpleado,
			   IDEmpleado,
			   Empleado,
			   IDJefe,
			   Jefe,
			   IDTipoRelacion
		FROM @dtInfoOrganigrama

		SET @Cont += 1;
	END
	

	-- OBTIENE EL EVALUADOR DEL COLABORADOR SEGUN SU RELACION (SUPERVISOR, SUBORDINADO, COLEGA)
	;WITH Tbl(IDEmpleadoAEvaluar, IDTipoRelacion, IDEvaluador, Evaluador) AS
	(
		SELECT *
		FROM(
			SELECT IDEmpleadoAEvaluar,
					IDTipoRelacion,
					CASE
						WHEN IDTipoRelacion = 1 
							THEN IDJefe
							ELSE IDEmpleado
						END AS IDEvaluador,
					CASE
						WHEN IDTipoRelacion = 1 
							THEN Jefe
							ELSE Empleado
						END AS Evaluador
			FROM @dtInfoOrganigramaAux
			GROUP BY IDEmpleadoAEvaluar, IDTipoRelacion, IDJefe, IDEmpleado, Jefe, Empleado
		) Info
	)
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY IDEmpleadoAEvaluar, IDEvaluador ORDER BY IDEmpleadoAEvaluar, IDTipoRelacion ASC) AS RN,
		   NEWID() AS Random
	INTO #tempHistorialEvaluadores
	FROM Tbl
	
				
	-- OBTIENE TODOS LOS EVALUADORES DISPONIBLES 
	--(SE UTILIZA PARA AQUELLOS EVALUADARES QUE PUEDEN EVALUAR AL COLABORADOR 2 VECES, LO CUAL NO ESTA PERMITIDO)
	SELECT *
	INTO #tempHistorialEvaluadoresAux
	FROM #tempHistorialEvaluadores THE
	WHERE THE.IDEmpleadoAEvaluar != IDEvaluador	

	-- ELIMINA LOS EVALUADORES QUE YA ESTAN ASIGNADOS AL COLABORADOR QUE SE PRETENDE EVALUAR 
	--(SE UTILIZA PARA AQUELLOS EVALUADARES QUE PUEDEN EVALUAR AL COLABORADOR 2 VECES, LO CUAL NO ESTA PERMITIDO)
	DELETE THE
	FROM #tempHistorialEvaluadoresAux THE
		JOIN @RelacionesProyecto RP ON RP.IDEmpleado = THE.IDEmpleadoAEvaluar AND 
									   RP.IDEvaluador = THE.IDEvaluador --AND
									   --RP.IDTipoRelacion = THE.IDTipoRelacion



	-- ELIMINA LOS EVALUADORES QUE SE REPITEN EN DIFERENTES RELACIONES
	-- (SE UTILIZA PARA AQUIELLOS EVALUADORES UNICOS)
	DELETE THE
	FROM #tempHistorialEvaluadores THE
	WHERE THE.RN > 1 OR 
		  THE.IDEmpleadoAEvaluar = THE.IDEvaluador

	
	-- ELIMINA LOS EVALUADORES QUE YA ESTAN ASIGNADOS AL COLABORADOR QUE SE PRETENDE EVALUAR
	-- (SE UTILIZA PARA AQUIELLOS EVALUADORES UNICOS)
	DELETE THE
	FROM #tempHistorialEvaluadores THE
		JOIN @RelacionesProyecto RP ON RP.IDEmpleado = THE.IDEmpleadoAEvaluar AND 
									   RP.IDEvaluador = THE.IDEvaluador --AND
									   --RP.IDTipoRelacion = THE.IDTipoRelacion	
	
		   
	-- ELIMINA LOS COLABORADORES QUE YA TIENEN ASIGNADO UN EVALUADOR EN DICHA RELACION
	DELETE @RelacionesProyecto WHERE ISNULL(IDEvaluacionEmpleado, 0) > 0 AND ISNULL(IDEvaluador, 0) > 0

	
	
	-- RE-ORDENA ROW_NUMBER EN LA COLUMNA RN (ESTO PORQUE HUBO ELIMINACIONES DE REGISTROS ANTERIORMENTE)
	;WITH Tbl(IDEmpleadoAEvaluar, IDTipoRelacion, IDEvaluador, RNAux) AS
	(
		SELECT IDEmpleadoAEvaluar,
			   IDTipoRelacion,
			   IDEvaluador,
			   ROW_NUMBER() OVER(PARTITION BY IDEmpleadoAEvaluar, IDTipoRelacion ORDER BY IDEmpleadoAEvaluar, IDTipoRelacion, Random) AS RNAux
		FROM #tempHistorialEvaluadores
	)
	UPDATE T2 SET T2.RN = T1.RNAux
	FROM Tbl T1
		JOIN #tempHistorialEvaluadores T2 ON T1.IDEmpleadoAEvaluar = T2.IDEmpleadoAEvaluar AND
											 T1.IDTipoRelacion = T2.IDTipoRelacion AND
											 T1.IDEvaluador = T2.IDEvaluador

	
	

	-- AGREGA ROW_NUMBER A LOS COLABORADORES Y SUS RELACIONES A EVALUAR
	SELECT *, ROW_NUMBER() OVER(PARTITION BY IDEmpleado, IDTipoRelacion ORDER BY IDEmpleado ASC) AS RN
	INTO #tempRelacionesProyecto
	FROM @RelacionesProyecto 

		
	-- ASIGNA EL EVALUADOR AL COLABORADOR SEGUN SU TIPO DE RELACION
	UPDATE TRP SET TRP.IDEvaluador = THE.IDEvaluador
	FROM #tempRelacionesProyecto TRP
		JOIN #tempHistorialEvaluadores THE on THE.IDEmpleadoAEvaluar = TRP.IDEmpleado AND
											  THE.IDTipoRelacion = TRP.IDTipoRelacion AND 
											  THE.RN = TRP.RN
	
	
	
	-- ASIGNA INDIVIDUALMENTE EL EVALUADOR AL COLABORADOR SEGUN SU TIPO DE RELACION, DEBIDO A LA DUPLICIDAD DE EVALUDADORES
	--(PROCESO QUE EVITA EVALUAR AL COLABORADOR 2 VECES)
	INSERT INTO @RelacionesProyectoAux
	SELECT * 	
	FROM #tempRelacionesProyecto
	WHERE IDEvaluador = 0	

	DECLARE @TotalSA INT = 0;
	SELECT @TotalSA = COUNT(*) FROM @RelacionesProyectoAux
	DECLARE @Contador INT = 1;

	WHILE(@Contador <= @TotalSA) 
	BEGIN
		
		DECLARE @IDEmpleadoAux INT = 0;
		DECLARE @IDTipoRelacionAux INT = 0;
		DECLARE @RN INT = 0;
		DECLARE @IDEvaluadorAux INT = 0;

		SELECT @IDEmpleadoAux = IDEmpleado, @IDTipoRelacionAux = IDTipoRelacion FROM @RelacionesProyectoAux WHERE ID = @Contador;				

		SELECT TOP 1 @IDEvaluadorAux = THE.IDEvaluador 
		FROM #tempHistorialEvaluadoresAux THE
		WHERE THE.IDEmpleadoAEvaluar = @IDEmpleadoAux AND
			  THE.IDTipoRelacion = @IDTipoRelacionAux AND
			  NOT EXISTS (SELECT TRP.IDEvaluador FROM #tempRelacionesProyecto TRP WHERE TRP.IDEvaluador = THE.IDEvaluador AND TRP.IDEmpleado = THE.IDEmpleadoAEvaluar) AND
			  NOT EXISTS (SELECT RPA.IDEvaluador FROM @RelacionesProyectoAux RPA WHERE RPA.IDEvaluador = THE.IDEvaluador AND RPA.IDEmpleado = THE.IDEmpleadoAEvaluar)
		ORDER BY Random

		UPDATE @RelacionesProyectoAux SET IDEvaluador = @IDEvaluadorAux WHERE ID = @Contador

		SET @Contador += 1;
	END	
	
	UPDATE TRP SET TRP.IDEvaluador = RPA.IDEvaluador
	FROM #tempRelacionesProyecto TRP
		JOIN @RelacionesProyectoAux RPA on RPA.IDEmpleadoProyecto = TRP.IDEmpleadoProyecto AND
										   RPA.IDProyecto = TRP.IDProyecto AND
										   RPA.IDEmpleado = TRP.IDEmpleado AND
										   RPA.IDTipoRelacion = TRP.IDTipoRelacion AND 
										   RPA.RN = TRP.RN
	WHERE TRP.IDEvaluador = 0
	-- TERMINA LA ASIGNACION INDIVIDUAL

	
	


	-- AQUI PODEMOS REVISAR EL RESULTADO
	/*
	SELECT * FROM #tempHistorialEvaluadores ORDER BY IDEmpleadoAEvaluar, IDTipoRelacion, Random
	SELECT * FROM #tempHistorialEvaluadoresAux ORDER BY IDEmpleadoAEvaluar, IDTipoRelacion, Random
	SELECT * FROM Evaluacion360.tblEvaluacionesEmpleados ORDER BY IDEmpleadoProyecto DESC
	SELECT * FROM #tempRelacionesProyecto ORDER BY IDEmpleadoProyecto
	return
	*/
	
	
	


	-- PROCESO FINAL (INSERCION DE EVALUADORES)
	BEGIN TRY
		BEGIN TRAN TransEvaEmpProyecto
			MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
			USING #tempRelacionesProyecto AS SOURCE
			ON TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto AND 
			   TARGET.IDTipoRelacion = SOURCE.IDTipoRelacion AND
			   ISNULL(TARGET.IDEvaluador,0) = 0
			WHEN MATCHED THEN
				UPDATE 
				SET TARGET.IDEvaluador = SOURCE.IDEvaluador
			WHEN NOT MATCHED BY TARGET AND SOURCE.IDEvaluador > 0 THEN
				INSERT(IDEmpleadoProyecto, IDTipoRelacion, IDEvaluador)
				VALUES(SOURCE.IDEmpleadoProyecto, SOURCE.IDTipoRelacion, SOURCE.IDEvaluador)
				--WHEN NOT MATCHED BY SOURCE and TARGET.IDTipoRelacion = 4 THEN 
				--DELETE
			OUTPUT
			$ACTION AS ActionType,
			INSERTED.IDEvaluacionEmpleado
			INTO @archive;
		COMMIT TRAN TransEvaEmpProyecto			
	END TRY
	BEGIN CATCH		
		ROLLBACK TRAN TransEvaEmpProyecto
		SELECT ERROR_MESSAGE() 
	END CATCH
	
	
	INSERT [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado, IDEstatus, IDUsuario)
	SELECT IDEvaluacionEmpleado, 11, @IDUsuario FROM @archive
	

	EXEC [Evaluacion360].[spActualizarProgresoProyecto]
		@IDProyecto = @IDProyecto
		, @IDUsuario = @IDUsuario

	EXEC [Evaluacion360].[spEstatusEsperandoAprobacion]
		@IDProyecto = @IDProyecto,
		@IDUsuario = @IDUsuario


	IF OBJECT_ID('tempdb..#tempEvaluadores') IS NOT NULL DROP TABLE #tempEvaluadores;
	IF OBJECT_ID('tempdb..#tempHistorialEvaluadores') IS NOT NULL DROP TABLE #tempHistorialEvaluadores;
	IF OBJECT_ID('tempdb..#tempRelacionesProyecto') IS NOT NULL DROP TABLE #tempRelacionesProyecto;
GO
