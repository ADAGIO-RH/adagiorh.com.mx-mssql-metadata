USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crea una tarea para informar a los editores que el proyecto ha sido terminado (todos los evaluadores han contestado).
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-01-08
** Parametros		: @IDProyecto				Identificador del proyecto
**					: @IDUsuario				Identificador del usuario
** IDAzure			: #1323

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spITareaDeProyectoFinalizado](
	@IDProyecto		INT = 0
	, @IDUsuario	INT = 0
)
AS
	BEGIN	  
		
		-- VARIABLES
		DECLARE @Tabla									VARCHAR(150)
				, @NoFinalizaciones						INT = 0
				, @FechaHora							DATETIME = DATEADD(MINUTE, 4, GETDATE())
				, @NombreTask							VARCHAR(255)
				, @INTERVAL								INT = 0
				, @ACTIVE								BIT = 1
				, @ACCION_GENERAR_NOTIFICACION_EMAIL	INT = 7
				, @IDTask								INT = 0
				, @IDSchedule							INT = 0
				, @Error								VARCHAR(MAX)				
				, @ID_TIPO_NOTIFICACION					VARCHAR(50) = 'ProyectoFinalizado'	
				;


		-- TABLA TEMPORAL
		DECLARE @ProyectosFinalizados TABLE(
			[Key] VARCHAR(2)
			, [Value] INT
			, IDUsuario INT
			, IDEmpleado INT
		)


		-- CREA FUENTE DE DATOS PARA DEL PROYECTO FINALIZADO
		EXEC [Evaluacion360].[spIProyectosFinalizados] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
		--SELECT * FROM [Evaluacion360].[tblProyectosFinalizados] WHERE IDProyecto = @IDProyecto
		

		-- OBTENEMOS LOS REGISTROS DEL PROYECTO FINALIZADO
		INSERT INTO @ProyectosFinalizados
		SELECT	'ID' AS [Key]
				, PF.ID AS [Value]					
				, PF.IDEditor AS IDUsuario
				, ISNULL(U.IDEmpleado, 0) AS IDEmpleado
		FROM [Evaluacion360].[tblProyectosFinalizados] PF
			JOIN [Seguridad].[tblUsuarios] U ON PF.IDEditor = U.IDUsuario
		WHERE IDProyecto = @IDProyecto
		
		
		-- OBTENEMOS EL NUMERO DE ITEMS DEL PROYECTO FINALIZADO
		SELECT @NoFinalizaciones = COUNT(*) 
		FROM @ProyectosFinalizados
		WHERE IDUsuario <> 0;


		IF(@NoFinalizaciones > 0)
			BEGIN

				BEGIN TRY
					BEGIN TRANSACTION;
			
						-- CONFIGURACIÓN DEL TIPO DE NOTIFICACIÓN EN LA TAREA
						DECLARE @JsonTask VARCHAR(MAX) = 
						'{' +
						'"BuscarDatos":false' +
						',"IDTipoNotificacion":"' + CAST(@ID_TIPO_NOTIFICACION AS VARCHAR(255)) + '"' +
						',"Tabla":"[Evaluacion360].[tblProyectosFinalizados]"' +
						',"IDUsuario":' + CAST(@IDUsuario AS VARCHAR(25)) +
						',"JsonValorIDCampo": ' + (SELECT * FROM @ProyectosFinalizados FOR JSON PATH) + '' +
						'}';
					

						-- OBTENEMOS EL NOMBRE DE LA TAREA EN MAYÚSCULAS
						SELECT @NombreTask = UPPER(Nombre)
						FROM [App].[tblTiposNotificaciones] 
						WHERE IDTipoNotificacion = @ID_TIPO_NOTIFICACION;
						

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
