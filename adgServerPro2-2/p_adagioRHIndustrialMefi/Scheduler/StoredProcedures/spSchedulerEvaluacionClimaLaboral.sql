USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Scheduler].[spSchedulerEvaluacionClimaLaboral](
	@IDProyecto INT
	,@IDEvaluacionEmpleado INT
)  
AS  
	BEGIN  
  
		DECLARE @FechaHora DATETIME = DATEADD(MINUTE, 2, GETDATE())
				,@sp VARCHAR(MAX)
				,@IDTask INT
				,@IDSchedule INT
				,@Activo INT = 1
				,@IDAccionStoreProcedure INT = 1
				;					


		SELECT @sp = FORMATMESSAGE('[InfoDir].[spSincronizarEvaluacionesClimaLaboral] @IDProyecto = ' + CAST(ISNULL(@IDProyecto, 0) AS VARCHAR(20)) + ', @IDEvaluacionEmpleado = ' + CAST(ISNULL(@IDEvaluacionEmpleado, 0) AS VARCHAR(20)) + '')
		INSERT INTO [Scheduler].[tblTask](Nombre, StoreProcedure, [interval], active, IDTipoAccion) 
		VALUES ('SINCRONIZA RESPUESTAS DE EVALUACIONES DE CLIMA LABORAL', @sp, 0, @Activo, @IDAccionStoreProcedure)

		SET @IDTask = @@IDENTITY

		INSERT INTO [Scheduler].[tblSchedule](  
			   IDTipoSchedule  
			  ,Nombre  
			  ,OneTimeDate  
			  ,OneTimeTime  
			  ,OcurrsFrecuency  
			  ,RecursEveryDaily  
			  ,RecursEveryWeek  
			  ,WeekDays  
			  ,MonthlyType  
			  ,MonthlyAbsoluteDayOfMonth  
			  ,MonthlyAbsoluteNumberOfMonths  
			  ,MonthlyRelativeDay  
			  ,MonthlyRelativeDayOfWeek  
			  ,MonthlyRelativeDayOfWeekShort  
			  ,MonthlyRelativeNumberOfMonths  
			  ,FrecuencyType  
			  ,DailyFrecuencyOnce  
			  ,MultipleFrecuencyValues  
			  ,MultipleFrecuencyValueTypes  
			  ,MultipleFrecuencyStartTime  
			  ,MultipleFrecuencyEndTime  
			  ,DurationStartDate  
			  ,DurationEndDate  
			  ,RunForever)  
	  VALUES(   
		(SELECT TOP 1 IDTipoSchedule FROM [Scheduler].[tblTipoSchedule] WHERE [Value] = 'OneTime')
		,'SINCRONIZA RESPUESTAS DE EVALUACIONES DE CLIMA LABORAL'  
		,CAST(@FechaHora AS DATE)
		,CAST(@FechaHora AS TIME)
		,ISNULL('Diario', '')  
		,0
		,0 
		,0
		,'Absolute'
		,0
		,0
		,'First'
		,'Some'
		,NULL
		,0
		,'Unica'
		,NULL
		,0
		,'Minutes'
		,NULL
		,NULL
		,isnull(@FechaHora,getdate())
		,isnull(@FechaHora,getdate())
		,0)

		SET @IDSchedule = @@IDENTITY
		
		INSERT INTO [Scheduler].[tblListSchedulersForTask](IDTask, IDSchedule)
		VALUES(@IDTask, @IDSchedule)
      
	END
GO
