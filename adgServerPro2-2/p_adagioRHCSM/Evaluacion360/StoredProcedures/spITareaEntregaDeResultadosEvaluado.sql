USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crea una tarea para enviar los resultados de una evaluacion a los colaboradores involucrados.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-12-20
** Parametros		: @IDProyecto			Identificador del proyecto
**					: @FilesEvaluaciones	Lista de archivos
** IDAzure			: #1303

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spITareaEntregaDeResultadosEvaluado](
	@IDProyecto				INT = 0
	, @FilesEvaluaciones	[App].[dtAdgFiles] READONLY	
)
AS
BEGIN

	/*
		TIPOS PROYECTOS CON SU IDTipoNotificacion

		*** EVALUADO
			1.- EVALUACIÓN 360				/ (EntregaDeResultadosEvaluadoEvaluacion360)
			2.- EVALUACIÓN DESEMPEÑO		/ (EntregaDeResultadosEvaluadoEvaluacionDesempeno)
			3.- EVALUACIÓN CLIMA LABORAL	/ (EntregaDeResultadosEvaluadoEvaluacionClimaLaboral)
			4.- EVALUACIÓN ENCUESTA			/ (EntregaDeResultadosEvaluadoEvaluacionEncuesta)
	*/    
		
	-- VARIABLES
	DECLARE @IDTipoNotificacionEvaluado				VARCHAR(50) = NULL
			, @TablaEvaluado						VARCHAR(150)			
			, @ContEvaluado							INT = 0
			, @IDUsuario							INT = 1
			, @FechaHora							DATETIME = DATEADD(MINUTE, 2, GETDATE())
			, @NombreTask							VARCHAR(255)
			, @INTERVAL								INT = 0
			, @ACTIVE								BIT = 1
			, @ACCION_GENERAR_NOTIFICACION_EMAIL	INT = 7
			, @IDTask								INT = 0
			, @IDSchedule							INT = 0
			, @Error								VARCHAR(MAX)
			, @IDTipoProyecto						INT = 0				
			;

	-- TABLA TEMPORAL
	DECLARE @TblEntregaDeResultadosEvaluado TABLE(
		IDEntregaDeResultado	INT
	);


	-- OBTENEMOS EL IDTipoProyecto
	SELECT @IDTipoProyecto = IDTipoProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto;
	
	-- OBTENEMOS DE LA FUNCION EL IDTipoNotificacion y Tabla A PARTIR DEL @IDTipoProyecto
	SELECT @IDTipoNotificacionEvaluado = IDTipoNotificacionEvaluado
			, @TablaEvaluado = TablaEvaluado
    FROM [Evaluacion360].[fnObtenerNotificacionEntregaDeResultadosEvaluado](@IDTipoProyecto);


	-- VALIDACIONES
	IF(@IDTipoProyecto = 0)
	BEGIN
		RAISERROR('No se encontró el IDTipoProyecto, por lo tanto no es posible asignarle un IDTipoNotificacion.', 16, 1);	
		RETURN;
	END

	IF(@IDTipoNotificacionEvaluado IS NULL)
	BEGIN	
		RAISERROR('No se encontró ningún IDTipoNotificacion ligado al tipo de proyecto.', 16, 1);		
		RETURN;
	END

	
	---- CREA FUENTE DE DATOS PARA LOS DIFERENTES TIPOS DE EVALUACIONES Y OBTIENE EL @IDRecordatorio RECIEN INSERTADO
	INSERT INTO @TblEntregaDeResultadosEvaluado
	EXEC [Evaluacion360].[spGenerarEntregaDeResultadosEvaluados] @IDProyecto, @FilesEvaluaciones;
	

	SELECT @ContEvaluado = COUNT(IDEntregaDeResultado) FROM @TblEntregaDeResultadosEvaluado;
	
	IF(@ContEvaluado > 0)
	BEGIN

		BEGIN TRY
			BEGIN TRANSACTION;

				-- CONFIGURACIÓN DEL TIPO DE NOTIFICACIÓN EN LA TAREA
				DECLARE @JsonTask VARCHAR(MAX) = 
				'{' +
				'"BuscarDatos":true' +		
				',"IDTipoNotificacion":"' + CAST(@IDTipoNotificacionEvaluado AS VARCHAR(255)) + '"' +
				',"Tabla":"' + CAST(@TablaEvaluado AS VARCHAR(255)) + '"' +
				',"IDUsuario":' + CAST(@IDUsuario AS VARCHAR(25)) +
				',"JsonBuscaValorIDCampo":{' +
											'"Param":[' +
														'{"Key":"IDProyecto","Value":' + CAST(@IDProyecto AS VARCHAR(255)) + '},' +
														'{"Key":"IDUsuario","Value":' + CAST(@IDUsuario AS VARCHAR(255)) + '}' +
													'],' +
											'"SP":"[Evaluacion360].[spBuscarEntregaDeResultadosEvaluado]",' +
											'"Result":{"PropIDOut":"IDEntregaDeResultado","PropIDIn":"IDEntregaDeResultado","PropIDUsuarioIn":"IDUsuarioEvaluado","PropIDEmpleadoIn":"IDEmpleadoEvaluado"}' +											
										 '}' +
				'}';


				-- OBTENEMOS EL NOMBRE DE LA TAREA EN MAYÚSCULAS
				SELECT @NombreTask = UPPER(Nombre)
				FROM [App].[tblTiposNotificaciones] 
				WHERE IDTipoNotificacion = @IDTipoNotificacionEvaluado;
			

				-- INSERTAR LA TAREA EN LA TABLA [Scheduler].[tblTask]
				INSERT INTO [Scheduler].[tblTask] 
				VALUES (@NombreTask, NULL, @INTERVAL, @ACTIVE, @ACCION_GENERAR_NOTIFICACION_EMAIL, @JsonTask);
        
				SET @IDTask = SCOPE_IDENTITY();



				-- INSERTAR EL CRONOGRAMA EN LA TABLA [Scheduler].[tblSchedule]
				INSERT INTO [Scheduler].[tblSchedule]
				(  
					IDTipoSchedule
					, Nombre
					, OneTimeDate
					, OneTimeTime
					, OcurrsFrecuency
					, RecursEveryDaily
					, RecursEveryWeek
					, WeekDays
					, MonthlyType
					, MonthlyAbsoluteDayOfMonth
					, MonthlyAbsoluteNumberOfMonths
					, MonthlyRelativeDay
					, MonthlyRelativeDayOfWeek
					, MonthlyRelativeDayOfWeekShort
					, MonthlyRelativeNumberOfMonths
					, FrecuencyType
					, DailyFrecuencyOnce
					, MultipleFrecuencyValues
					, MultipleFrecuencyValueTypes
					, MultipleFrecuencyStartTime
					, MultipleFrecuencyEndTime
					, DurationStartDate
					, DurationEndDate
					, RunForever
				)
				VALUES
				(
					(SELECT TOP 1 IDTipoSchedule FROM Scheduler.tblTipoSchedule WHERE [Value] = 'OneTime')
					, @NombreTask
					, CAST(@FechaHora AS DATE)
					, CAST(@FechaHora AS TIME)
					, ISNULL('Diario', '')
					, 0
					, 0
					, 0
					, 'Absolute'
					, 0
					, 0
					, 'First'
					, 'Some'
					, NULL
					, 0
					, 'Unica'
					, NULL
					, 0
					, 'Minutes'
					, NULL
					, NULL
					, ISNULL(@FechaHora, GETDATE())
					, ISNULL(@FechaHora, GETDATE())
					, 0
				);
        
				SET @IDSchedule = SCOPE_IDENTITY();



				-- LIGAR LA TAREA CON EL CRONOGRAMA EN LA TABLA [Scheduler].[tblListSchedulersForTask]
				INSERT INTO [Scheduler].[tblListSchedulersForTask](IDTask, IDSchedule)
				VALUES(@IDTask, @IDSchedule); 



				--RESULTADO
				--SELECT * FROM [Scheduler].[tblTask]  WHERE IDTask = @IDTask;
				--SELECT * FROM [Scheduler].[tblSchedule] WHERE IDSchedule = @IDSchedule;
				--SELECT * FROM [Scheduler].[tblListSchedulersForTask] WHERE IDTask = @IDTask AND IDSchedule = @IDSchedule;
		
        
				COMMIT TRANSACTION;

			END TRY
			BEGIN CATCH        
				ROLLBACK TRANSACTION;

					SELECT @Error = ERROR_MESSAGE();
					RAISERROR(@Error, 16, 1);
        
			END CATCH;		
		END
	
	END
GO
