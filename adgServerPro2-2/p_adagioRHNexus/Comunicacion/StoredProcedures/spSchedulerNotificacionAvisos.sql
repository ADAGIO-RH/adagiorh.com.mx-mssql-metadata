USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Comunicacion].[spSchedulerNotificacionAvisos]
(
	@IDAviso		INT = 0	
	, @IDUsuario	INT = 0
	, @Reenviar		BIT = 0
	, @IDEmpleado	INT = 0	
)  
AS  
	BEGIN

		DECLARE @FechaHora		DATETIME = DATEADD(MINUTE, 2, GETDATE())
				, @sp			VARCHAR(MAX)
				, @IDTask		INT
				, @IDSchedule	INT
				;
		
		IF(@Reenviar = 0) -- MANDAR A TODOS (GENERAL O FILTROS)
			BEGIN
				SELECT @sp = CONCAT(' [Comunicacion].[spBuscarEmpleadosForEnvioNotificacion] @IDAviso = ', @IDAviso, ', @IDUsuario =' , @IDUsuario);
			END
		ELSE
			BEGIN -- REENVIAR A COLABORADOR
				SELECT @sp = CONCAT(' [Comunicacion].[spBuscarEmpleadosForEnvioNotificacion] @IDAviso = ', @IDAviso, ', @IDUsuario =' , @IDUsuario, ', @Reenviar =' , @Reenviar, ', @IDEmpleado =' , @IDEmpleado);
			END
		
		INSERT INTO [Scheduler].[tblTask](Nombre, StoreProcedure, [interval], active, IDTipoAccion) VALUES('GENERAR NOTIFICACION DE AVISOS', @sp, 0, 1, 5);

		SET @IDTask = @@IDENTITY;

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
			, 'GENERAR NOTIFICACION DE AVISOS'
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
		)


		SET @IDSchedule = @@IDENTITY;

		INSERT INTO [Scheduler].[tblListSchedulersForTask](IDTask, IDSchedule)
		VALUES(@IDTask, @IDSchedule);

END
GO
