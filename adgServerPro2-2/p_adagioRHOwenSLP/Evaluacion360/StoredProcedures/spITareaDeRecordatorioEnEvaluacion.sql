USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crea una tarea para enviar recordatorios a los colaboradores con evaluaciones pendientes.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-12-11
** Parametros		: @IDProyecto				Identificador del proyecto
**					: @IDEvaluacionEmpleado		Identificador de la evaluación
**					: @IDUsuario				Identificador del usuario
** IDAzure			: #1286

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spITareaDeRecordatorioEnEvaluacion](
	@IsGeneral				INT = 0
	, @IDProyecto			INT = 0
	, @IDEvaluacionEmpleado	INT = 0
	, @IDEvaluador			INT = 0	
	, @IDUsuario			INT = 0
)
AS
BEGIN

	/*
		TIPOS PROYECTOS CON SU IDTipoNotificacion
		1.- EVALUACIÓN 360				/ (RecordatorioEvaluacionPendiente360)
		2.- EVALUACIÓN DESEMPEÑO		/ (RecordatorioEvaluacionPendienteDesempeno)
		3.- EVALUACIÓN CLIMA LABORAL	/ (RecordatorioEvaluacionPendienteClimaLaboral)
		4.- EVALUACIÓN ENCUESTA			/ (RecordatorioEvaluacionPendienteEncuesta)
	*/    
		
	-- VARIABLES
	DECLARE @Tabla									VARCHAR(150)
			, @IDRecordatorio						INT = 0
			, @FechaHora							DATETIME = DATEADD(MINUTE, 2, GETDATE())
			, @NombreTask							VARCHAR(255)
			, @INTERVAL								INT = 0
			, @ACTIVE								BIT = 1
			, @ACCION_GENERAR_NOTIFICACION_EMAIL	INT = 7
			, @IDTask								INT = 0
			, @IDSchedule							INT = 0
			, @Error								VARCHAR(MAX)
			, @IDTipoProyecto						INT = 0
			, @IDTipoNotificacion					VARCHAR(50) = NULL	
			;

	-- TABLA TEMPORAL
	DECLARE @TblRecordatorio TABLE(
		IDRecordatorio	INT
		, IDEvaluador	INT
	);


	-- OBTENEMOS EL IDTipoProyecto
	SELECT @IDTipoProyecto = IDTipoProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto;
	
	-- OBTENEMOS DE LA FUNCION EL IDTipoNotificacion y Tabla A PARTIR DEL @IDTipoProyecto
	SELECT @IDTipoNotificacion = IDTipoNotificacion
			, @Tabla = Tabla			
    FROM [Evaluacion360].[fnObtenerNotificacionRecordatorio](@IDTipoProyecto);


	-- VALIDACIONES
	IF(@IDTipoProyecto = 0)
	BEGIN
		RAISERROR('No se encontró el IDTipoProyecto, por lo tanto no es posible asignarle un IDTipoNotificacion.', 16, 1);	
		RETURN;
	END

	IF(@IDTipoNotificacion IS NULL)
	BEGIN	
		RAISERROR('No se encontró ningún IDTipoNotificacion ligado al tipo de proyecto.', 16, 1);		
		RETURN;
	END


	-- CREA FUENTE DE DATOS PARA LOS DIFERENTES TIPOS DE EVALUACIONES Y OBTIENE EL @IDRecordatorio RECIEN INSERTADO
	INSERT INTO @TblRecordatorio
	EXEC [Evaluacion360].[spGenerarRecordatorios] @IsGeneral, @IDProyecto, @IDEvaluacionEmpleado, @IDEvaluador, @IDUsuario;
		
	SELECT @IDRecordatorio = IDRecordatorio
			, @IDEvaluador = IDEvaluador
	FROM @TblRecordatorio;


	IF(@IDRecordatorio > 0)
	BEGIN

		BEGIN TRY
			BEGIN TRANSACTION;				

				SELECT @IDUsuario = IDUsuario FROM [Seguridad].[tblUsuarios] WHERE IDEmpleado = @IDEvaluador;
			
				-- CONFIGURACIÓN DEL TIPO DE NOTIFICACIÓN EN LA TAREA
				DECLARE @JsonTask VARCHAR(MAX) = 
				'{' +
				'"BuscarDatos":false' +
				',"IDTipoNotificacion":"' + CAST(@IDTipoNotificacion AS VARCHAR(255)) + '"' +
				',"Tabla":"'+ CAST(@Tabla AS VARCHAR(255)) +'"' +
				',"IDUsuario":' + CAST(@IDUsuario AS VARCHAR(25)) +
				',"JsonValorIDCampo":[{"Key":"IDRecordatorio","Value":' + CAST(@IDRecordatorio AS VARCHAR(25)) + ',"IDUsuario":' + CAST(@IDUsuario AS VARCHAR(25)) + ',"IDEmpleado":' + CAST(@IDEvaluador AS VARCHAR(25)) + '}]' +
				'}';


				-- OBTENEMOS EL NOMBRE DE LA TAREA EN MAYÚSCULAS
				SELECT @NombreTask = UPPER(Nombre)
				FROM [App].[tblTiposNotificaciones] 
				WHERE IDTipoNotificacion = @IDTipoNotificacion;
			

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
