USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crea una tarea que enviará invitaciones a los colaboradores asignados para realizar una evaluación.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-10-03
** Parametros		: @JsonTask		Json que contiene la configuración de la tarea a realizar en el proximo minuto.
**					: @IDUsuario	Identificador del usuario
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spITareaDeInvitacionEnEvaluacion](
	@IDProyecto		INT
	, @IDUsuario	INT
)
AS
BEGIN
    
	/*
		TIPOS PROYECTOS CON SU IDTipoNotificacion
		1.- EVALUACIÓN 360				/ (InvitacionRealizar360)
		2.- EVALUACIÓN DESEMPEÑO		/ (InvitacionRealizarDesempeno)
		3.- EVALUACIÓN CLIMA LABORAL	/ (InvitacionRealizarClimaLaboral)
		4.- EVALUACIÓN ENCUESTA			/ (InvitacionRealizarEncuesta)
	*/    

	DECLARE @FechaHora								DATETIME = DATEADD(MINUTE, 2, GETDATE())
			, @NombreTask							VARCHAR(255)
			, @INTERVAL								INT = 0
			, @ACTIVE								BIT = 1
			, @ACCION_GENERAR_NOTIFICACION_EMAIL	INT = 7
			, @IDTask								INT = 0
			, @IDSchedule							INT = 0
			, @Error								VARCHAR(MAX)
			, @IDTipoProyecto						INT = 0
			, @IDTipoNotificacion					VARCHAR(50) = NULL
			, @Tabla								VARCHAR(100) = NULL			
			;


	-- OBTENEMOS EL IDTipoProyecto A PARTIR DEL JSON
	SELECT @IDTipoProyecto = IDTipoProyecto FROM Evaluacion360.tblCatProyectos WHERE IDProyecto = @IDProyecto;

	-- OBTENEMOS DE LA FUNCION EL IDTipoNotificacion y Tabla A PARTIR DEL @IDTipoProyecto
	SELECT @IDTipoNotificacion = IDTipoNotificacion
			, @Tabla = Tabla			
    FROM [Evaluacion360].[fnObtenerNotificacionInvitacion](@IDTipoProyecto);

		
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
	

	BEGIN TRY
        BEGIN TRANSACTION;
		
		-- CONFIGURACIÓN DEL TIPO DE NOTIFICACIÓN EN LA TAREA
		DECLARE @JsonTask VARCHAR(MAX) = 
		'{' +
		'"BuscarDatos":true' +		
		',"IDTipoNotificacion":"' + CAST(@IDTipoNotificacion AS VARCHAR(255)) + '"' +
		',"Tabla":"' + CAST(@Tabla AS VARCHAR(255)) + '"' +
		',"IDUsuario":' + CAST(@IDUsuario AS VARCHAR(25)) +
		',"JsonBuscaValorIDCampo":{' +
									'"Param":[' +
												'{"Key":"IDProyecto","Value":' + CAST(@IDProyecto AS VARCHAR(255)) + '},' +
												'{"Key":"IDUsuario","Value":' + CAST(@IDUsuario AS VARCHAR(255)) + '}' +
											'],' +
									'"SP":"[Evaluacion360].[spBuscarEvaluacionesSinInvitacionEmail]",' +
									'"Result":{"PropIDOut":"IDInvitacion","PropIDIn":"IDInvitacion","PropIDUsuarioIn":"IDUsuarioEvaluador","PropIDEmpleadoIn":"IDEmpleadoEvaluador"}' +
								 '}' +
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
GO
