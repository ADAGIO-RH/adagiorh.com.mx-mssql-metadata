USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spSchedulerMigracionExpedienteDigital]  
(  
     @IDUsuario int = 0
    ,@IDCandidatoPlaza int  = 0
    ,@ClaveEmpleado varchar(max) 
    ,@IDEmpleado int = 0
)  
AS  
BEGIN  
  
  DECLARE 
		@FechaHora datetime = dateadd(MINUTE,2,getdate()),  
		@IDSchedule int,  
		@IDTask int  ;
	    
    DECLARE @sp varchar(max);    
    DECLARE @TIPO_ACCION_ALTA_EXPEDIENTE int =8;        
    declare @Nombre varchar(max);

    SELECT @sp = concat('[Reclutamiento].[spMigrarExpedienteDigitalCandidatoEmpleado] @IDUsuario=' ,@IDUsuario,',@IDCandidatoPlaza=',@IDCandidatoPlaza,',@ClaveEmpleado=''',@ClaveEmpleado,''',@IDEmpleado=',@IDEmpleado)    
    SET @Nombre='MIGRAR EXPEDIENTE DIGITAL CANDIDATO A EMPLEADO';

    IF object_id('tempdb..#tempTask') IS NOT NULL DROP TABLE #tempTask;

	CREATE TABLE #tempTask (
		IDTask	int	 
		,Nombre	varchar(255)
		,StoreProcedure	varchar(250)
		,interval	int	
		,active	bit	
		,IDTipoAccion	int	
		,TipoAccion	varchar(250)
	);
    INSERT #tempTask
    EXEC [Scheduler].[spUITask] @IDTask = 0
										,@Nombre = @Nombre
										,@StoreProcedure = @sp
										,@interval = 1
										,@active =1 
										,@IDTipoAccion = @TIPO_ACCION_ALTA_EXPEDIENTE
										,@IDUsuario = @IDUsuario;

    SELECT TOP 1 @IDTask = tt.IDTask from #tempTask tt;
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
			(SELECT top 1 IDTipoSchedule FROM Scheduler.tblTipoSchedule where [Value] = 'OneTime')  
			,'MIGRAR EXPEDIENTE DIGITAL CANDIDATO A EMPLEADO'  
			,cast(@FechaHora as date)  
			,cast(@FechaHora as time)  
			,isnull('Diario','')  
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
			,2  
			,'Minutes'  
			,NULL  
			,NULL  
			,isnull(@FechaHora,getdate())  
			,isnull(@FechaHora,getdate())  
			,0
		)    
		SET @IDSchedule = @@IDENTITY    
		insert into Scheduler.tblListSchedulersForTask(IDTask,IDSchedule)  
		values(@IDTask,@IDSchedule)  


END
GO
