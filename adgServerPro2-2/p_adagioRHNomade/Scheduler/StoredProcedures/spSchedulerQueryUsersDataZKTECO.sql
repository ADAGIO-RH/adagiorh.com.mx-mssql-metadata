USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   PROCEDURE [Scheduler].[spSchedulerQueryUsersDataZKTECO](  
	@DevSN varchar(50),
	@PINs varchar(max)
)  
AS  
BEGIN  
  
    DECLARE @FechaHora datetime = dateadd(MINUTE,2,getdate())
    DECLARE @sp varchar(max)
    DECLARE @IDTask int 
    DECLARE @IDSchedule int 

    select @sp = FORMATMESSAGE('[zkteco].[spQueryPins] @DevSN=''%s'', @PINs=''%s''', @DevSN, @PINs)
    insert into Scheduler.tblTask(Nombre, StoreProcedure,[interval],active,IDTipoAccion) 
	values ('QUERY USER DATA - ZKTECO',@sp,0,1,3)

    set @IDTask = @@IDENTITY      

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
    ,'QUERY USER DATA - ZKTECO'  
    , cast(@FechaHora as date)  
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
    ,0  
    ,'Minutes'  
    ,NULL  
    ,NULL  
    ,isnull(@FechaHora,getdate())  
    ,isnull(@FechaHora,getdate())  
    ,0)      
    set @IDSchedule = @@IDENTITY      
    insert into Scheduler.tblListSchedulersForTask(IDTask,IDSchedule)  
    values(@IDTask,@IDSchedule)  
      
END
GO
